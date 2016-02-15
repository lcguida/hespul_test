class Site < ActiveRecord::Base
  has_many :daily_productions, class_name: "SiteDailyProduction"
  has_many :meters, -> { order installation_date: :desc }
  has_one :active_meter, -> { where active: true }, class_name: "Meter"

  before_create :create_new_meter

  validates :name, presence: true

  #Retrouve un index pour un jour specifié
  def acumulated_production_at(date)
    #Trouver tous les compteur jusqu'à date saissé, organisé par date
    meters_until_date = meters.where(Meter.arel_table[:installation_date].lteq(date))
                        .by_date

    production_until_date = 0

    # Pour chaque compteur, calculer leur production total, scahant que
    # la production total c'est la différence du premier index
    # et le dernier index
    meters_until_date.each do |meter|
      initial_reading = meter.first_reading.value
      last_reading = meter.reading_at_or_before(date).value
      production_until_date += (last_reading - initial_reading).abs
    end

    return production_until_date
  end

  # Changer le compteur d'un site
  # C'est possible de passer le index initial du nouveau compteur
  # si non cet index sera zèro.
  def update_meter(meter_params, value = 0)
    active_meter.uninstall
    meter_params[:active] = true
    new_meter = meters.create(meter_params)
    new_meter.create_first_reading(value)
  end

  # Crée des index qui n'existent pas à partir des productions jounalières
  def create_missing_readings_from_daily_productions
    daily_productions.each do |daily_production|
      date = daily_production.date
      meter = meter_at(date)
      reading_at_date = meter.readings.where(date: date).first

      # S'Il y a un index à cette date ou L'index a été saissé ou importer
      # on ne peut pas modifier cet index
      if !reading_at_date || reading_at_date.calculated?
        last_reading_value = meter.reading_at_or_before(date).value
        meter.readings.create({
          date: date,
          value: last_reading_value + daily_production.production,
          source: MeterReading.sources[:calculated]
        })
      end

    end
  end

  private
  # Quand on crée un nouveau site, il faut aussi créer un compateur
  # et un valeur de production cumulée
  def create_new_meter
    meters.build({
      installation_date: created_at,
      active: true
    })
  end

  # Retrouve le meter actif du site à la date donnée
  def meter_at(date)
    meters_table = Meter.arel_table
    #Les conditions
    installation_after_date = meters_table[:installation_date].lteq(date)
    uninstallation_before_date = meters_table[:uninstallation_date].gteq(date)
    uninstallation_nil = meters_table[:uninstallation_date].eq(nil)
    meters.where(installation_after_date)
         .where(uninstallation_before_date.or(uninstallation_nil))
         .first
  end
end
