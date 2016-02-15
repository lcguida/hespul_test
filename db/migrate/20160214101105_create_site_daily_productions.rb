class CreateSiteDailyProductions < ActiveRecord::Migration
  def change
    create_table :site_daily_productions do |t|
      t.references :site, index: true, foreign_key: true, null: false
      t.integer :production, null: false
      t.date :date, null: false
    end
  end
end
