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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130708145811) do

  create_table "accounts", :force => true do |t|
    t.string   "login"
    t.string   "password"
    t.string   "last_name"
    t.string   "first_name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "games", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",                                                         :null => false
    t.datetime "updated_at",                                                         :null => false
    t.spatial  "area",                    :limit => {:srid=>4326, :type=>"polygon"}
    t.spatial  "treasure_loc",            :limit => {:srid=>4326, :type=>"point"}
    t.integer  "treasure_holder_id"
    t.integer  "allowed_inactivity_time"
  end

  create_table "players", :force => true do |t|
    t.string   "name"
    t.integer  "game_id"
    t.datetime "created_at",                                          :null => false
    t.datetime "updated_at",                                          :null => false
    t.spatial  "loc",        :limit => {:srid=>4326, :type=>"point"}
    t.integer  "account_id"
  end

  add_index "players", ["loc"], :name => "index_players_on_loc", :spatial => true

end
