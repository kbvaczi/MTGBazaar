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

ActiveRecord::Schema.define(:version => 20120122150248) do

  create_table "accounts", :force => true do |t|
    t.integer  "user_id"
    t.string   "first_name",        :default => "",    :null => false
    t.string   "last_name",         :default => "",    :null => false
    t.string   "country",           :default => "",    :null => false
    t.string   "state",             :default => "",    :null => false
    t.string   "city",              :default => "",    :null => false
    t.string   "address1",          :default => "",    :null => false
    t.string   "address2",          :default => "",    :null => false
    t.string   "zipcode",           :default => "",    :null => false
    t.string   "paypal_username",   :default => "",    :null => false
    t.string   "security_question", :default => "",    :null => false
    t.string   "security_answer",   :default => "",    :null => false
    t.integer  "balance",           :default => 0,     :null => false
    t.integer  "number_sales",      :default => 0,     :null => false
    t.integer  "number_purchases",  :default => 0,     :null => false
    t.float    "average_rating",    :default => 0.0,   :null => false
    t.float    "average_ship_time", :default => 0.0,   :null => false
    t.boolean  "vacation",          :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "accounts", ["user_id"], :name => "index_accounts_on_user_id"

  create_table "mtg_blocks", :force => true do |t|
    t.string   "name",       :default => "", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "mtg_blocks", ["name"], :name => "index_mtg_blocks_on_name"

  create_table "mtg_cards", :force => true do |t|
    t.integer  "set_id"
    t.string   "name",                      :default => "", :null => false
    t.string   "type",                      :default => "", :null => false
    t.string   "subtype",                   :default => "", :null => false
    t.string   "rarity",                    :default => "", :null => false
    t.string   "artist",                    :default => "", :null => false
    t.string   "description",               :default => "", :null => false
    t.string   "mana_string",               :default => "", :null => false
    t.string   "mana_color",                :default => "", :null => false
    t.string   "mana_cost",                 :default => "", :null => false
    t.string   "power",                     :default => "", :null => false
    t.string   "toughness",                 :default => "", :null => false
    t.string   "legality_block",            :default => "", :null => false
    t.string   "legality_standard",         :default => "", :null => false
    t.string   "legality_extended",         :default => "", :null => false
    t.string   "legality_modern",           :default => "", :null => false
    t.string   "legality_legacy",           :default => "", :null => false
    t.string   "legality_vintage",          :default => "", :null => false
    t.string   "legality_highlander",       :default => "", :null => false
    t.string   "legality_french_commander", :default => "", :null => false
    t.string   "legality_commander",        :default => "", :null => false
    t.string   "legality_peasant",          :default => "", :null => false
    t.string   "legality_pauper",           :default => "", :null => false
    t.string   "multiverse_id",             :default => "", :null => false
    t.string   "image_path",                :default => "", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "mtg_cards", ["artist"], :name => "index_mtg_cards_on_artist"
  add_index "mtg_cards", ["mana_color"], :name => "index_mtg_cards_on_mana_color"
  add_index "mtg_cards", ["mana_cost"], :name => "index_mtg_cards_on_mana_cost"
  add_index "mtg_cards", ["name"], :name => "index_mtg_cards_on_name"
  add_index "mtg_cards", ["power"], :name => "index_mtg_cards_on_power"
  add_index "mtg_cards", ["rarity"], :name => "index_mtg_cards_on_rarity"
  add_index "mtg_cards", ["set_id"], :name => "index_mtg_cards_on_set_id"
  add_index "mtg_cards", ["toughness"], :name => "index_mtg_cards_on_toughness"
  add_index "mtg_cards", ["type"], :name => "index_mtg_cards_on_type"

  create_table "mtg_sets", :force => true do |t|
    t.integer  "block_id"
    t.string   "name",         :default => "",                    :null => false
    t.string   "code",         :default => "",                    :null => false
    t.datetime "release_date", :default => '2012-01-23 20:06:21'
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "mtg_sets", ["code"], :name => "index_mtg_sets_on_code"
  add_index "mtg_sets", ["name"], :name => "index_mtg_sets_on_name"
  add_index "mtg_sets", ["release_date"], :name => "index_mtg_sets_on_release_date"

  create_table "transactions", :force => true do |t|
    t.integer  "test1_id"
    t.integer  "test2_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                                 :default => "", :null => false
    t.string   "encrypted_password",     :limit => 128, :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.integer  "failed_attempts",                       :default => 0
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.string   "authentication_token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_level",                            :default => 0
    t.string   "username"
  end

  add_index "users", ["authentication_token"], :name => "index_users_on_authentication_token", :unique => true
  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["unlock_token"], :name => "index_users_on_unlock_token", :unique => true

end
