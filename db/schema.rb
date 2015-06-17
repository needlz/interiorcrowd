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

ActiveRecord::Schema.define(version: 20150617082907) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: true do |t|
    t.string   "namespace"
    t.text     "body"
    t.string   "resource_id",   null: false
    t.string   "resource_type", null: false
    t.integer  "author_id"
    t.string   "author_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree

  create_table "admin_users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admin_users", ["email"], name: "index_admin_users_on_email", unique: true, using: :btree
  add_index "admin_users", ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true, using: :btree

  create_table "appeals", force: true do |t|
    t.string "name"
  end

  create_table "beta_subscribers", force: true do |t|
    t.text     "email"
    t.string   "role"
    t.text     "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "clients", force: true do |t|
    t.text     "first_name"
    t.text     "last_name"
    t.text     "email"
    t.string   "password"
    t.text     "name_on_card"
    t.text     "card_type"
    t.text     "address"
    t.text     "state"
    t.integer  "zip"
    t.text     "card_number"
    t.integer  "card_ex_month"
    t.integer  "card_ex_year"
    t.integer  "card_cvc"
    t.integer  "status",             default: 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "designer_level_id"
    t.text     "city"
    t.text     "phone_number"
    t.text     "billing_address"
    t.text     "billing_state"
    t.integer  "billing_zip"
    t.text     "billing_city"
    t.string   "plain_password"
    t.string   "stripe_customer_id"
    t.text     "stripe_card_status", default: "pending"
  end

  add_index "clients", ["email"], name: "index_clients_on_email", unique: true, using: :btree

  create_table "concept_board_comments", force: true do |t|
    t.integer  "user_id"
    t.text     "text"
    t.integer  "contest_request_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "role"
    t.integer  "contest_note_id"
  end

  create_table "contest_notes", force: true do |t|
    t.text     "text"
    t.integer  "contest_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "designer_id"
    t.integer  "client_id"
  end

  add_index "contest_notes", ["contest_id"], name: "index_contest_notes_on_contest_id", using: :btree

  create_table "contest_requests", force: true do |t|
    t.integer  "designer_id"
    t.integer  "contest_id"
    t.text     "designs"
    t.text     "feedback"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lookbook_id"
    t.string   "answer"
    t.string   "status",             default: "draft"
    t.text     "final_note"
    t.text     "pull_together_note"
    t.string   "token"
  end

  create_table "contests", force: true do |t|
    t.text     "desirable_colors"
    t.text     "undesirable_colors"
    t.string   "space_budget"
    t.text     "feedback"
    t.text     "project_name"
    t.integer  "budget_plan"
    t.integer  "client_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "space_length",                    precision: 10, scale: 2, default: 0.0
    t.decimal  "space_width",                     precision: 10, scale: 2, default: 0.0
    t.decimal  "space_height",                    precision: 10, scale: 2
    t.integer  "design_category_id"
    t.integer  "design_space_id"
    t.string   "status",                                                   default: "submission"
    t.datetime "phase_end"
    t.string   "theme"
    t.string   "space"
    t.string   "accessories"
    t.string   "space_changes"
    t.string   "shop"
    t.boolean  "accommodate_children"
    t.boolean  "accommodate_pets"
    t.text     "retailer"
    t.text     "elements_to_avoid"
    t.integer  "entertaining"
    t.integer  "durability"
    t.integer  "preferred_retailers_id"
    t.boolean  "designers_explore_other_colors",                           default: false
    t.boolean  "designers_only_use_these_colors",                          default: false
  end

  create_table "contests_appeals", force: true do |t|
    t.integer "contest_id"
    t.integer "appeal_id"
    t.text    "reason"
    t.integer "value"
  end

  add_index "contests_appeals", ["appeal_id", "contest_id"], name: "index_contests_appeals_on_appeal_id_and_contest_id", using: :btree
  add_index "contests_appeals", ["contest_id", "appeal_id"], name: "index_contests_appeals_on_contest_id_and_appeal_id", using: :btree

  create_table "contests_images", force: true do |t|
    t.integer "contest_id"
    t.integer "image_id"
    t.integer "kind"
  end

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",           default: 0, null: false
    t.integer  "attempts",           default: 0, null: false
    t.text     "handler",                        null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "contest_id"
    t.string   "image_type"
    t.integer  "contest_request_id"
    t.integer  "outbound_email_id"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "design_categories", force: true do |t|
    t.text     "name"
    t.integer  "pos"
    t.integer  "price"
    t.integer  "status",     default: 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "design_spaces", force: true do |t|
    t.text     "name"
    t.integer  "pos"
    t.integer  "parent_id"
    t.integer  "status",     default: 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "designer_levels", force: true do |t|
    t.integer "level"
    t.text    "name"
  end

  create_table "designers", force: true do |t|
    t.text     "first_name"
    t.text     "last_name"
    t.text     "email"
    t.string   "password"
    t.text     "zip"
    t.text     "ex_links"
    t.text     "ex_document_ids"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "portfolio_background_id"
    t.text     "portfolio_path"
    t.text     "phone_number"
    t.text     "plain_password"
    t.string   "state"
    t.text     "address"
    t.text     "city"
  end

  add_index "designers", ["email"], name: "index_designers_on_email", unique: true, using: :btree

  create_table "example_links", force: true do |t|
    t.text     "url"
    t.integer  "portfolio_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "image_items", force: true do |t|
    t.text     "name"
    t.integer  "contest_request_id"
    t.integer  "image_id"
    t.text     "text"
    t.decimal  "price"
    t.text     "brand"
    t.text     "link"
    t.string   "mark"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "kind"
    t.text     "dimensions"
    t.boolean  "final",              default: false
    t.integer  "price_cents"
    t.string   "price_currency",     default: "USD", null: false
  end

  create_table "image_links", force: true do |t|
    t.integer "contest_id"
    t.text    "url"
  end

  create_table "images", force: true do |t|
    t.string   "image"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.string   "image_file_size"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "contest_id"
    t.string   "kind"
    t.integer  "designer_id"
    t.integer  "portfolio_id"
    t.string   "uploader_role"
    t.integer  "uploader_id"
  end

  create_table "lookbook_details", force: true do |t|
    t.integer  "lookbook_id"
    t.integer  "image_id"
    t.text     "description"
    t.text     "url"
    t.integer  "doc_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "phase"
  end

  create_table "lookbooks", force: true do |t|
    t.integer  "contest_id"
    t.text     "feedback"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "outbound_emails", force: true do |t|
    t.string   "mailer_method"
    t.text     "mail_args"
    t.string   "status",                 default: "not yet sent"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "sent_to_mail_server_at"
  end

  create_table "portfolio_awards", force: true do |t|
    t.integer  "portfolio_id"
    t.text     "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "portfolios", force: true do |t|
    t.integer "designer_id",                             null: false
    t.integer "years_of_experience"
    t.boolean "education_gifted"
    t.boolean "education_school"
    t.boolean "education_apprenticed"
    t.text    "school_name"
    t.text    "degree"
    t.text    "awards"
    t.text    "style_description"
    t.text    "about"
    t.text    "path"
    t.boolean "modern_style",            default: false
    t.boolean "vintage_style",           default: false
    t.boolean "traditional_style",       default: false
    t.boolean "contemporary_style",      default: false
    t.boolean "coastal_style",           default: false
    t.boolean "global_style",            default: false
    t.boolean "eclectic_style",          default: false
    t.boolean "hollywood_glam_style",    default: false
    t.boolean "midcentury_modern_style", default: false
    t.boolean "transitional_style",      default: false
    t.boolean "rustic_elegance_style",   default: false
    t.boolean "color_pop_style",         default: false
    t.integer "background_id"
    t.integer "cover_width"
    t.float   "cover_x_percents_offset"
    t.float   "cover_y_percents_offset"
  end

  create_table "preferred_retailers", force: true do |t|
    t.boolean  "anthropologie_home",   default: false
    t.boolean  "ballard_designs",      default: false
    t.boolean  "crate_and_barrel",     default: false
    t.boolean  "etsy",                 default: false
    t.boolean  "gilt",                 default: false
    t.boolean  "horchow",              default: false
    t.boolean  "ikea",                 default: false
    t.boolean  "one_kings_lane",       default: false
    t.boolean  "pier_one",             default: false
    t.boolean  "pottery_barn",         default: false
    t.boolean  "restoration_hardware", default: false
    t.boolean  "room_and_board",       default: false
    t.boolean  "target",               default: false
    t.boolean  "wayfair",              default: false
    t.boolean  "west_elm",             default: false
    t.text     "other"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "promocodes", force: true do |t|
    t.integer "client_id"
    t.text    "token"
    t.text    "profit"
  end

  add_index "promocodes", ["client_id"], name: "index_promocodes_on_client_id", using: :btree

  create_table "reviewer_feedbacks", force: true do |t|
    t.text     "text"
    t.integer  "invitation_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "reviewer_feedbacks", ["invitation_id"], name: "index_reviewer_feedbacks_on_invitation_id", using: :btree

  create_table "reviewer_invitations", force: true do |t|
    t.text     "username"
    t.text     "email"
    t.integer  "contest_id"
    t.text     "url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "reviewer_invitations", ["contest_id"], name: "index_reviewer_invitations_on_contest_id", using: :btree

  create_table "sessions", force: true do |t|
    t.string   "session_id", null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", unique: true, using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "sounds", force: true do |t|
    t.integer  "contest_request_id"
    t.string   "audio_file_name"
    t.string   "audio_content_type"
    t.integer  "audio_file_size"
    t.datetime "audio_updated_at"
  end

  create_table "user_notifications", force: true do |t|
    t.integer  "user_id"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "contest_id"
    t.integer  "contest_request_id"
    t.boolean  "read",                     default: false
    t.integer  "contest_comment_id"
    t.integer  "concept_board_comment_id"
  end

  add_index "user_notifications", ["contest_id"], name: "index_user_notifications_on_contest_id", using: :btree
  add_index "user_notifications", ["user_id"], name: "index_user_notifications_on_user_id", using: :btree

end
