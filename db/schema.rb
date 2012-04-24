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

ActiveRecord::Schema.define(:version => 20120422115231) do

  create_table "account_balance_transfers", :force => true do |t|
    t.integer  "account_id"
    t.integer  "balance",            :default => 0,  :null => false
    t.string   "current_sign_in_ip", :default => "", :null => false
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
  end

  add_index "account_balance_transfers", ["account_id"], :name => "index_account_balance_transfers_on_account_id"

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
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
  end

  add_index "accounts", ["user_id"], :name => "index_accounts_on_user_id"

  create_table "active_admin_comments", :force => true do |t|
    t.integer  "resource_id",   :null => false
    t.string   "resource_type", :null => false
    t.integer  "author_id"
    t.string   "author_type"
    t.text     "body"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "namespace"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], :name => "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], :name => "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], :name => "index_admin_notes_on_resource_type_and_resource_id"

  create_table "admin_users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "admin_users", ["email"], :name => "index_admin_users_on_email", :unique => true
  add_index "admin_users", ["reset_password_token"], :name => "index_admin_users_on_reset_password_token", :unique => true

  create_table "carts", :force => true do |t|
    t.integer  "user_id"
    t.integer  "total_price", :default => 0, :null => false
    t.integer  "item_count",  :default => 0, :null => false
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  add_index "carts", ["user_id"], :name => "index_carts_on_user_id"

  create_table "mtg_blocks", :force => true do |t|
    t.string   "name",       :default => "",   :null => false
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.boolean  "active",     :default => true, :null => false
  end

  add_index "mtg_blocks", ["active"], :name => "index_mtg_blocks_on_active"
  add_index "mtg_blocks", ["name"], :name => "index_mtg_blocks_on_name"

  create_table "mtg_cards", :force => true do |t|
    t.integer  "set_id"
    t.string   "name",            :default => "",   :null => false
    t.string   "card_type",       :default => "",   :null => false
    t.string   "card_subtype",    :default => "",   :null => false
    t.string   "rarity",          :default => "",   :null => false
    t.string   "artist",          :default => "",   :null => false
    t.text     "description",     :default => "",   :null => false
    t.string   "mana_string",     :default => "",   :null => false
    t.string   "mana_color",      :default => "",   :null => false
    t.string   "mana_cost",       :default => "",   :null => false
    t.string   "power",           :default => "",   :null => false
    t.string   "toughness",       :default => "",   :null => false
    t.string   "multiverse_id",   :default => "",   :null => false
    t.string   "image_path",      :default => "",   :null => false
    t.string   "image_back_path", :default => "",   :null => false
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.string   "card_number"
    t.boolean  "active",          :default => true, :null => false
  end

  add_index "mtg_cards", ["active"], :name => "index_mtg_cards_on_active"
  add_index "mtg_cards", ["artist"], :name => "index_mtg_cards_on_artist"
  add_index "mtg_cards", ["card_subtype"], :name => "index_mtg_cards_on_card_subtype"
  add_index "mtg_cards", ["card_type"], :name => "index_mtg_cards_on_card_type"
  add_index "mtg_cards", ["mana_color"], :name => "index_mtg_cards_on_mana_color"
  add_index "mtg_cards", ["name"], :name => "index_mtg_cards_on_name"
  add_index "mtg_cards", ["rarity"], :name => "index_mtg_cards_on_rarity"
  add_index "mtg_cards", ["set_id"], :name => "index_mtg_cards_on_set_id"

  create_table "mtg_listings", :force => true do |t|
    t.integer  "card_id"
    t.integer  "seller_id"
    t.integer  "transaction_id"
    t.integer  "cart_id"
    t.integer  "price",              :default => 100,   :null => false
    t.integer  "quantity",           :default => 1,     :null => false
    t.integer  "quantity_available", :default => 1,     :null => false
    t.string   "condition",          :default => "1",   :null => false
    t.string   "language",           :default => "EN",  :null => false
    t.string   "description",        :default => "",    :null => false
    t.boolean  "signed",             :default => false, :null => false
    t.boolean  "misprint",           :default => false, :null => false
    t.boolean  "foil",               :default => false, :null => false
    t.boolean  "altart",             :default => false, :null => false
    t.boolean  "reserved",           :default => false, :null => false
    t.boolean  "active",             :default => true,  :null => false
    t.datetime "sold_at"
    t.datetime "rejected_at"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
  end

  add_index "mtg_listings", ["card_id"], :name => "index_mtg_listings_on_card_id"
  add_index "mtg_listings", ["cart_id"], :name => "index_mtg_listings_on_cart_id"
  add_index "mtg_listings", ["seller_id"], :name => "index_mtg_listings_on_seller_id"
  add_index "mtg_listings", ["transaction_id"], :name => "index_mtg_listings_on_transaction_id"

  create_table "mtg_reservations", :force => true do |t|
    t.integer  "cart_id"
    t.integer  "listing_id"
    t.integer  "quantity",   :default => 0, :null => false
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "mtg_reservations", ["cart_id"], :name => "index_mtg_reservations_on_cart_id"
  add_index "mtg_reservations", ["listing_id"], :name => "index_mtg_reservations_on_listing_id"

  create_table "mtg_sets", :force => true do |t|
    t.integer  "block_id"
    t.string   "name",         :default => "",           :null => false
    t.string   "code",         :default => "",           :null => false
    t.date     "release_date", :default => '2012-03-14'
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.boolean  "active",       :default => false,        :null => false
  end

  add_index "mtg_sets", ["active"], :name => "index_mtg_sets_on_active"
  add_index "mtg_sets", ["code"], :name => "index_mtg_sets_on_code"
  add_index "mtg_sets", ["name"], :name => "index_mtg_sets_on_name"
  add_index "mtg_sets", ["release_date"], :name => "index_mtg_sets_on_release_date"

  create_table "mtg_transaction_items", :force => true do |t|
    t.integer  "card_id"
    t.integer  "seller_id"
    t.integer  "buyer_id"
    t.integer  "transaction_id"
    t.integer  "price",          :default => 100,   :null => false
    t.integer  "quantity",       :default => 1,     :null => false
    t.string   "condition",      :default => "1",   :null => false
    t.string   "language",       :default => "EN",  :null => false
    t.string   "description",    :default => "",    :null => false
    t.boolean  "signed",         :default => false, :null => false
    t.boolean  "misprint",       :default => false, :null => false
    t.boolean  "foil",           :default => false, :null => false
    t.boolean  "altart",         :default => false, :null => false
    t.datetime "rejected_at"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
  end

  add_index "mtg_transaction_items", ["buyer_id"], :name => "index_mtg_transaction_items_on_buyer_id"
  add_index "mtg_transaction_items", ["card_id"], :name => "index_mtg_transaction_items_on_card_id"
  add_index "mtg_transaction_items", ["seller_id"], :name => "index_mtg_transaction_items_on_seller_id"
  add_index "mtg_transaction_items", ["transaction_id"], :name => "index_mtg_transaction_items_on_transaction_id"

  create_table "mtg_transactions", :force => true do |t|
    t.integer  "buyer_id"
    t.integer  "seller_id"
    t.datetime "buyer_confirmed_at"
    t.datetime "seller_confirmed_at"
    t.datetime "seller_rejected_at"
    t.string   "rejection_reason",            :default => ""
    t.string   "rejection_message",           :default => ""
    t.datetime "seller_shipped_at"
    t.string   "seller_tracking_number",      :default => ""
    t.datetime "seller_delivered_at"
    t.boolean  "buyer_delivery_confirmation"
    t.integer  "seller_rating"
    t.string   "buyer_feedback",              :default => ""
    t.string   "status",                      :default => ""
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
  end

  add_index "mtg_transactions", ["buyer_id"], :name => "index_mtg_transactions_on_buyer_id"
  add_index "mtg_transactions", ["seller_id"], :name => "index_mtg_transactions_on_seller_id"
  add_index "mtg_transactions", ["status"], :name => "index_mtg_transactions_on_status"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "transactions", :force => true do |t|
    t.integer  "test1_id"
    t.integer  "test2_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "password_salt"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",        :default => 0
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.string   "authentication_token"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.integer  "user_level",             :default => 0
    t.string   "username"
    t.boolean  "banned"
  end

  add_index "users", ["authentication_token"], :name => "index_users_on_authentication_token", :unique => true
  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["unlock_token"], :name => "index_users_on_unlock_token", :unique => true

end
