class CreateSites < ActiveRecord::Migration
  def change
    create_table :sites do |t|
      t.string :name, null: false
      t.decimal :latitude
      t.decimal :longitude
      t.timestamp :created_at, null: false
    end
  end
end
