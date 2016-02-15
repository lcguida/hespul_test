class CreateMeters < ActiveRecord::Migration
  def change
    create_table :meters do |t|
      t.references :site, index: true, foreign_key: true, null: false
      t.boolean :active, default: true
      t.date :installation_date, null: false
      t.date :uninstallation_date
    end
  end
end
