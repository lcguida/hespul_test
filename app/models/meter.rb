class Meter < ActiveRecord::Base

  belongs_to :site
  has_many :readings, class_name: "MeterReading"

  validates :installation_date, :site, presence: true
  validate :installation_date_must_be_after_site_creation

  after_create :create_first_reading

  scope :by_date, -> { order(installation_date: :asc) }

  # Désinstaller un compteur veut dire le faire devenir
  # inactif et metre un date de désintallation.
  # Comme ça, on peut savoir tous les changements de compteurs
  # qu'on a arrivé
  def uninstall
    update(uninstallation_date: Date.today, active: false)
  end

  #Créér un nouveau index pour le compteur avec le valeur passé
  def create_first_reading(value = 0)
    readings.create({
      # Si c'est le premier index, la date est la même que la date de
      # installation du compteur
      date: installation_date,
      value: value,
      # Le premier index est toujours saissé pour l'utilisateur, parce que
      # c'est lui qui crée le site ou le compteur.
      source: MeterReading.sources[:user]
    })
  end

  def first_reading
    readings.by_date.first
  end

  # Retrouve l'index à une date donée. S'il n'y a pas un index à ce jour
  # retrouve le plus récent index.
  def reading_at_or_before(date)
    before_or_at_date = MeterReading.arel_table[:date].lteq(date)
    readings.where(before_or_at_date).order(date: :asc).last
  end

  private
  def installation_date_must_be_after_site_creation
    return unless site
    return unless installation_date
    if installation_date < site.created_at.to_date
      errors.add(:installation_date, "cannot be before site's creation date")
    end
  end

end
