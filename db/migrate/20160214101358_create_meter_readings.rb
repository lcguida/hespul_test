class CreateMeterReadings < ActiveRecord::Migration
  def change
    create_table :meter_readings do |t|
      t.references :meter, index: true, foreign_key: true, null: false
      t.integer :value, null: false
      t.date :date, null: false
      t.integer :source, null: false
    end
  end
end
