class MeterReading < ActiveRecord::Base

  enum source: [:user, :import, :calculated]

  belongs_to :meter

  validates :date, :source, :value, :meter, presence: true

  validate :date_must_be_after_meter_installation
  validate :value_must_be_greater_than_meter_last_reading

  validate :source_priority, on: :update

  scope :by_date, -> { order(date: :asc) }


  private
  #La date d'un index doit être postérieur à la date d'installation du compteur
  def date_must_be_after_meter_installation
    if meter && date && meter.installation_date > date
      errors.add(:date, "cannot be before meter installation on the site")
    end
  end

  #Le nouveau index doit être plus grand que le dernier index
  def value_must_be_greater_than_meter_last_reading
    before_date = MeterReading.arel_table[:date].lteq(date)
    last_reading = MeterReading.where(before_date).where(meter_id: meter_id).last

    if last_reading && value && last_reading.value > value
      errors.add(:value, "cannot be lesser than meter's last reading")
    end
  end

  #Pour créer un index le utilisateur a la priorité sur l'import qui a la
  #priorité sur le calcul
  def source_priority
    if source && source_was > source
      errors[:base] << "A reading created by #{source_was} cannot be override by #{source}"
    end
  end

end
