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

ActiveRecord::Schema.define(version: 20150804221136) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "montages", force: true do |t|
    t.integer  "source_id"
    t.integer  "crop_x"
    t.integer  "crop_y"
    t.integer  "crop_width"
    t.integer  "crop_height"
    t.string   "image"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status",      default: "queued", null: false
    t.text     "error"
    t.string   "gif_image"
  end

  create_table "sources", force: true do |t|
    t.string   "image",      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
