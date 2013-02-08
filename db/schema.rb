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

ActiveRecord::Schema.define(:version => 20130117144431) do

  create_table "accounts", :force => true do |t|
    t.integer  "user_id"
    t.string   "first_name",                :default => "", :null => false
    t.string   "last_name",                 :default => "", :null => false
    t.string   "country",                   :default => "", :null => false
    t.string   "state",                     :default => "", :null => false
    t.string   "city",                      :default => "", :null => false
    t.string   "address1",                  :default => "", :null => false
    t.string   "address2",                  :default => "", :null => false
    t.string   "zipcode",                   :default => "", :null => false
    t.string   "paypal_username",           :default => "", :null => false
    t.string   "security_question",         :default => "", :null => false
    t.integer  "balance",                   :default => 0,  :null => false
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.string   "address_verification"
    t.float    "commission_rate"
    t.string   "encrypted_security_answer"
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

  create_table "admin_slider_center_slides", :force => true do |t|
    t.integer  "news_feed_id"
    t.string   "title"
    t.string   "description"
    t.string   "image"
    t.string   "link_type",    :default => "URL"
    t.string   "link"
    t.integer  "slide_number"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

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
    t.string   "nickname"
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

  create_table "ckeditor_assets", :force => true do |t|
    t.string   "data_file_name",                  :null => false
    t.string   "data_content_type"
    t.integer  "data_file_size"
    t.integer  "assetable_id"
    t.string   "assetable_type",    :limit => 30
    t.string   "type",              :limit => 30
    t.integer  "width"
    t.integer  "height"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  add_index "ckeditor_assets", ["assetable_type", "assetable_id"], :name => "idx_ckeditor_assetable"
  add_index "ckeditor_assets", ["assetable_type", "type", "assetable_id"], :name => "idx_ckeditor_assetable_type"

  create_table "communications", :force => true do |t|
    t.integer  "sender_id"
    t.string   "sender_type"
    t.integer  "receiver_id"
    t.integer  "mtg_transaction_id"
    t.text     "message"
    t.boolean  "unread",             :default => true
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
  end

  add_index "communications", ["mtg_transaction_id"], :name => "index_communications_on_mtg_transaction_id"
  add_index "communications", ["receiver_id"], :name => "index_communications_on_receiver_id"
  add_index "communications", ["sender_id"], :name => "index_communications_on_sender_id"

  create_table "mtg_blocks", :force => true do |t|
    t.string   "name",       :default => "",   :null => false
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.boolean  "active",     :default => true, :null => false
  end

  add_index "mtg_blocks", ["active"], :name => "index_mtg_blocks_on_active"
  add_index "mtg_blocks", ["name"], :name => "index_mtg_blocks_on_name"

  create_table "mtg_card_statistics", :force => true do |t|
    t.integer  "card_id"
    t.integer  "number_sales",       :default => 0
    t.integer  "price_low",          :default => 10
    t.integer  "price_med",          :default => 100
    t.integer  "price_high",         :default => 500
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.integer  "price_min",          :default => 0
    t.integer  "listings_available", :default => 0
  end

  add_index "mtg_card_statistics", ["card_id"], :name => "index_mtg_card_statistics_on_card_id"

  create_table "mtg_cards", :force => true do |t|
    t.integer  "set_id"
    t.string   "name",          :default => "",   :null => false
    t.string   "card_type",     :default => "",   :null => false
    t.string   "card_subtype",  :default => "",   :null => false
    t.string   "rarity",        :default => "",   :null => false
    t.string   "artist",        :default => "",   :null => false
    t.text     "description",                     :null => false
    t.string   "mana_string",   :default => "",   :null => false
    t.string   "mana_color",    :default => "",   :null => false
    t.string   "mana_cost",     :default => "",   :null => false
    t.string   "power",         :default => "",   :null => false
    t.string   "toughness",     :default => "",   :null => false
    t.string   "multiverse_id", :default => "",   :null => false
    t.string   "image_path",    :default => "",   :null => false
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.string   "card_number"
    t.boolean  "active",        :default => true, :null => false
  end

  add_index "mtg_cards", ["active"], :name => "index_mtg_cards_on_active"
  add_index "mtg_cards", ["artist"], :name => "index_mtg_cards_on_artist"
  add_index "mtg_cards", ["card_subtype"], :name => "index_mtg_cards_on_card_subtype"
  add_index "mtg_cards", ["card_type"], :name => "index_mtg_cards_on_card_type"
  add_index "mtg_cards", ["mana_color"], :name => "index_mtg_cards_on_mana_color"
  add_index "mtg_cards", ["name"], :name => "index_mtg_cards_on_name"
  add_index "mtg_cards", ["rarity"], :name => "index_mtg_cards_on_rarity"
  add_index "mtg_cards", ["set_id"], :name => "index_mtg_cards_on_set_id"

  create_table "mtg_cards_abilities", :force => true do |t|
    t.string "name", :default => ""
  end

  create_table "mtg_decklists", :force => true do |t|
    t.integer  "author_id"
    t.string   "name"
    t.string   "mana_string"
    t.string   "play_format"
    t.string   "event"
    t.boolean  "active"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "mtg_decklists", ["active"], :name => "index_mtg_decklists_on_active"
  add_index "mtg_decklists", ["author_id"], :name => "index_mtg_decklists_on_author_id"
  add_index "mtg_decklists", ["name"], :name => "index_mtg_decklists_on_name"

  create_table "mtg_decklists_card_references", :force => true do |t|
    t.integer  "decklist_id"
    t.integer  "card_id"
    t.string   "card_name"
    t.string   "deck_section"
    t.string   "deck_subsection"
    t.integer  "quantity"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "mtg_decklists_card_references", ["card_name"], :name => "index_mtg_decklists_card_references_on_card_name"
  add_index "mtg_decklists_card_references", ["decklist_id"], :name => "index_mtg_decklists_card_references_on_decklist_id"

  create_table "mtg_listings", :force => true do |t|
    t.integer  "card_id"
    t.integer  "seller_id"
    t.integer  "price",                 :default => 100,   :null => false
    t.integer  "quantity",              :default => 1,     :null => false
    t.integer  "quantity_available",    :default => 1,     :null => false
    t.string   "condition",             :default => "1",   :null => false
    t.string   "language",              :default => "EN",  :null => false
    t.string   "description",           :default => "",    :null => false
    t.boolean  "signed",                :default => false, :null => false
    t.boolean  "misprint",              :default => false, :null => false
    t.boolean  "foil",                  :default => false, :null => false
    t.boolean  "altart",                :default => false, :null => false
    t.boolean  "reserved",              :default => false, :null => false
    t.boolean  "active",                :default => true,  :null => false
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
    t.string   "scan",                  :default => ""
    t.integer  "number_cards_per_item", :default => 1
    t.boolean  "playset",               :default => false
  end

  add_index "mtg_listings", ["altart"], :name => "index_mtg_listings_on_altart"
  add_index "mtg_listings", ["card_id"], :name => "index_mtg_listings_on_card_id"
  add_index "mtg_listings", ["foil"], :name => "index_mtg_listings_on_foil"
  add_index "mtg_listings", ["language"], :name => "index_mtg_listings_on_language"
  add_index "mtg_listings", ["misprint"], :name => "index_mtg_listings_on_misprint"
  add_index "mtg_listings", ["seller_id"], :name => "index_mtg_listings_on_seller_id"
  add_index "mtg_listings", ["signed"], :name => "index_mtg_listings_on_signed"

  create_table "mtg_orders", :force => true do |t|
    t.integer  "cart_id"
    t.integer  "seller_id"
    t.integer  "item_count"
    t.integer  "item_price_total"
    t.integer  "shipping_cost"
    t.integer  "total_cost"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.integer  "cards_quantity"
    t.text     "shipping_options"
  end

  add_index "mtg_orders", ["cart_id"], :name => "index_mtg_orders_on_cart_id"
  add_index "mtg_orders", ["seller_id"], :name => "index_mtg_orders_on_seller_id"

  create_table "mtg_reservations", :force => true do |t|
    t.integer  "listing_id"
    t.integer  "quantity",       :default => 0, :null => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.integer  "order_id"
    t.integer  "cards_quantity"
  end

  add_index "mtg_reservations", ["listing_id"], :name => "index_mtg_reservations_on_listing_id"
  add_index "mtg_reservations", ["order_id"], :name => "index_mtg_reservations_on_order_id"

  create_table "mtg_sets", :force => true do |t|
    t.integer  "block_id"
    t.string   "name",         :default => "",           :null => false
    t.string   "code",         :default => "",           :null => false
    t.date     "release_date", :default => '2013-01-27'
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
    t.integer  "price",                 :default => 100,   :null => false
    t.string   "condition",             :default => "1",   :null => false
    t.string   "language",              :default => "EN",  :null => false
    t.string   "description",           :default => "",    :null => false
    t.boolean  "signed",                :default => false, :null => false
    t.boolean  "misprint",              :default => false, :null => false
    t.boolean  "foil",                  :default => false, :null => false
    t.boolean  "altart",                :default => false, :null => false
    t.datetime "rejected_at"
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
    t.integer  "quantity_available"
    t.integer  "quantity_requested"
    t.integer  "number_cards_per_item", :default => 1
    t.boolean  "playset",               :default => false
  end

  add_index "mtg_transaction_items", ["buyer_id"], :name => "index_mtg_transaction_items_on_buyer_id"
  add_index "mtg_transaction_items", ["card_id"], :name => "index_mtg_transaction_items_on_card_id"
  add_index "mtg_transaction_items", ["seller_id"], :name => "index_mtg_transaction_items_on_seller_id"
  add_index "mtg_transaction_items", ["transaction_id"], :name => "index_mtg_transaction_items_on_transaction_id"

  create_table "mtg_transaction_payments", :force => true do |t|
    t.integer  "user_id"
    t.integer  "transaction_id"
    t.datetime "created_at",                                      :null => false
    t.datetime "updated_at",                                      :null => false
    t.string   "paypal_paykey"
    t.string   "paypal_transaction_number"
    t.text     "paypal_purchase_response"
    t.string   "status",                    :default => "unpaid"
    t.integer  "amount",                    :default => 0
    t.integer  "commission",                :default => 0
    t.integer  "shipping_cost",             :default => 0
    t.float    "commission_rate",           :default => 0.0
  end

  add_index "mtg_transaction_payments", ["transaction_id"], :name => "index_mtg_transaction_payments_on_transaction_id"
  add_index "mtg_transaction_payments", ["user_id"], :name => "index_mtg_transaction_payments_on_user_id"

  create_table "mtg_transactions", :force => true do |t|
    t.integer  "buyer_id"
    t.integer  "seller_id"
    t.string   "transaction_number"
    t.datetime "buyer_confirmed_at"
    t.datetime "seller_confirmed_at"
    t.datetime "seller_rejected_at"
    t.string   "rejection_reason",       :default => ""
    t.string   "response_message",       :default => ""
    t.datetime "seller_shipped_at"
    t.string   "seller_tracking_number", :default => ""
    t.datetime "seller_delivered_at"
    t.string   "buyer_feedback",         :default => "P"
    t.string   "buyer_feedback_text",    :default => ""
    t.datetime "buyer_cancelled_at"
    t.string   "cancellation_reason",    :default => ""
    t.string   "status",                 :default => "pending"
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
    t.integer  "value"
    t.integer  "shipping_cost"
    t.integer  "order_id"
    t.integer  "cards_quantity"
    t.text     "shipping_options"
  end

  add_index "mtg_transactions", ["buyer_id"], :name => "index_mtg_transactions_on_buyer_id"
  add_index "mtg_transactions", ["order_id"], :name => "index_mtg_transactions_on_order_id"
  add_index "mtg_transactions", ["seller_id"], :name => "index_mtg_transactions_on_seller_id"
  add_index "mtg_transactions", ["status"], :name => "index_mtg_transactions_on_status"
  add_index "mtg_transactions", ["transaction_number"], :name => "index_mtg_transactions_on_transaction_number"

  create_table "mtg_transactions_feedback", :force => true do |t|
    t.integer  "transaction_id"
    t.string   "rating"
    t.string   "comment"
    t.string   "seller_response_comment"
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  add_index "mtg_transactions_feedback", ["rating"], :name => "index_mtg_transactions_feedback_on_rating"
  add_index "mtg_transactions_feedback", ["transaction_id"], :name => "index_mtg_transactions_feedback_on_transaction_id"

  create_table "mtg_transactions_payment_notifications", :force => true do |t|
    t.integer  "payment_id"
    t.text     "response"
    t.string   "status"
    t.string   "paypal_transaction_id"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
  end

  add_index "mtg_transactions_payment_notifications", ["payment_id"], :name => "index_mtg_transactions_payment_notifications_on_payment_id"

  create_table "mtg_transactions_shipping_labels", :force => true do |t|
    t.integer  "transaction_id"
    t.string   "stamps_tx_id"
    t.integer  "price"
    t.string   "status",         :default => "active"
    t.text     "params"
    t.text     "tracking"
    t.text     "refund"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
    t.text     "to_address"
    t.text     "from_address"
  end

  add_index "mtg_transactions_shipping_labels", ["transaction_id"], :name => "shipping_labels_transactions_id"

  create_table "news_feeds", :force => true do |t|
    t.integer  "author_id"
    t.string   "title",       :default => ""
    t.text     "data"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.datetime "start_at"
    t.datetime "end_at"
    t.boolean  "active",      :default => true
    t.string   "description"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "site_variables", :force => true do |t|
    t.string   "name"
    t.text     "value"
    t.datetime "start_at"
    t.datetime "end_at"
    t.boolean  "active",     :default => true
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
  end

  add_index "site_variables", ["active"], :name => "index_site_variables_on_active"
  add_index "site_variables", ["name"], :name => "index_site_variables_on_name"

  create_table "team_z_articles", :force => true do |t|
    t.integer  "team_z_profile_id"
    t.string   "title"
    t.string   "description"
    t.text     "body"
    t.string   "status"
    t.boolean  "active"
    t.boolean  "featured"
    t.datetime "active_at"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  add_index "team_z_articles", ["active"], :name => "index_team_z_articles_on_active"
  add_index "team_z_articles", ["status"], :name => "index_team_z_articles_on_status"
  add_index "team_z_articles", ["team_z_profile_id"], :name => "index_team_z_articles_on_team_z_profile_id"

  create_table "team_z_mtgo_video_series", :force => true do |t|
    t.integer  "team_z_profile_id"
    t.string   "title"
    t.string   "description"
    t.boolean  "active"
    t.datetime "active_at"
    t.boolean  "featured"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  add_index "team_z_mtgo_video_series", ["active"], :name => "index_team_z_mtgo_video_series_on_active"
  add_index "team_z_mtgo_video_series", ["team_z_profile_id"], :name => "index_team_z_mtgo_video_series_on_team_z_profile_id"

  create_table "team_z_mtgo_videos", :force => true do |t|
    t.integer  "video_series_id"
    t.string   "title"
    t.string   "video_link"
    t.string   "video_number"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "team_z_mtgo_videos", ["video_series_id"], :name => "index_team_z_mtgo_videos_on_video_series_id"

  create_table "team_z_profiles", :force => true do |t|
    t.string   "display_name"
    t.string   "avatar"
    t.string   "picture"
    t.text     "data"
    t.boolean  "can_write_articles"
    t.string   "article_series_name"
    t.boolean  "can_post_videos"
    t.boolean  "can_stream"
    t.string   "twitch_tv_username"
    t.boolean  "can_manage_content"
    t.boolean  "active"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  create_table "ticket_updates", :force => true do |t|
    t.integer  "ticket_id"
    t.integer  "author_id"
    t.string   "author_type"
    t.text     "description"
    t.boolean  "complete_ticket", :default => false
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
  end

  add_index "ticket_updates", ["author_id"], :name => "index_ticket_updates_on_author_id"
  add_index "ticket_updates", ["author_type"], :name => "index_ticket_updates_on_author_type"
  add_index "ticket_updates", ["ticket_id"], :name => "index_ticket_updates_on_ticket_id"

  create_table "tickets", :force => true do |t|
    t.integer  "transaction_id"
    t.string   "transaction_type"
    t.integer  "author_id"
    t.string   "author_type"
    t.integer  "offender_id"
    t.string   "problem",          :default => ""
    t.text     "description"
    t.string   "ticket_number",    :default => ""
    t.string   "status",           :default => "new"
    t.boolean  "strike",           :default => false
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
  end

  add_index "tickets", ["author_id"], :name => "index_tickets_on_author_id"
  add_index "tickets", ["author_type"], :name => "index_tickets_on_author_type"
  add_index "tickets", ["offender_id"], :name => "index_tickets_on_offender_id"
  add_index "tickets", ["transaction_id"], :name => "index_tickets_on_transaction_id"
  add_index "tickets", ["transaction_type"], :name => "index_tickets_on_transaction_type"

  create_table "user_statistics", :force => true do |t|
    t.integer  "user_id"
    t.integer  "number_purchases",           :default => 0
    t.integer  "number_sales",               :default => 0
    t.integer  "number_sales_cancelled",     :default => 0
    t.float    "average_ship_time"
    t.integer  "positive_feedback_count",    :default => 0
    t.integer  "negative_feedback_count",    :default => 0
    t.integer  "neutral_feedback_count",     :default => 0
    t.text     "ip_log"
    t.integer  "number_strikes",             :default => 0
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
    t.float    "approval_percent",           :default => 0.0
    t.integer  "number_sales_with_feedback", :default => 0
    t.integer  "listings_mtg_cards_count",   :default => 0
  end

  add_index "user_statistics", ["approval_percent"], :name => "index_user_statistics_on_approval_percent"
  add_index "user_statistics", ["number_sales"], :name => "index_user_statistics_on_number_sales"
  add_index "user_statistics", ["user_id"], :name => "index_user_statistics_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "",    :null => false
    t.string   "encrypted_password",     :default => "",    :null => false
    t.string   "username",                                  :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.boolean  "banned",                 :default => false
    t.string   "password_salt"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",        :default => 0
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.string   "authentication_token"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.integer  "user_level",             :default => 0
    t.boolean  "active",                 :default => false
    t.integer  "team_z_profile_id"
  end

  add_index "users", ["authentication_token"], :name => "index_users_on_authentication_token", :unique => true
  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["unlock_token"], :name => "index_users_on_unlock_token", :unique => true
  add_index "users", ["username"], :name => "index_users_on_username", :unique => true

end
