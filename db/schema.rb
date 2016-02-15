# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160214101358) do

  create_table "meter_readings", force: :cascade do |t|
    t.integer "meter_id", null: false
    t.integer "value",    null: false
    t.date    "date",     null: false
    t.integer "source",   null: false
  end

  add_index "meter_readings", ["meter_id"], name: "index_meter_readings_on_meter_id"

  create_table "meters", force: :cascade do |t|
    t.integer "site_id",                            null: false
    t.boolean "active",              default: true
    t.date    "installation_date",                  null: false
    t.date    "uninstallation_date"
  end

  add_index "meters", ["site_id"], name: "index_meters_on_site_id"

  create_table "site_daily_productions", force: :cascade do |t|
    t.integer "site_id",    null: false
    t.integer "production", null: false
    t.date    "date",       null: false
  end

  add_index "site_daily_productions", ["site_id"], name: "index_site_daily_productions_on_site_id"

  create_table "sites", force: :cascade do |t|
    t.string   "name",       null: false
    t.decimal  "latitude"
    t.decimal  "longitude"
    t.datetime "created_at", null: false
  end

end
