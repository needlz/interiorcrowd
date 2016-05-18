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

ActiveRecord::Schema.define(version: 20160418073906) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pg_stat_statements"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string   "namespace",     limit: 255
    t.text     "body"
    t.string   "resource_id",   limit: 255, null: false
    t.string   "resource_type", limit: 255, null: false
    t.integer  "author_id"
    t.string   "author_type",   limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree

  create_table "admin_users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admin_users", ["email"], name: "index_admin_users_on_email", unique: true, using: :btree
  add_index "admin_users", ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true, using: :btree

  create_table "appeals", force: :cascade do |t|
    t.string "name", limit: 255
  end

  create_table "beta_subscribers", force: :cascade do |t|
    t.text     "email"
    t.string   "role",       limit: 255
    t.text     "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "client_payments", force: :cascade do |t|
    t.integer  "client_id"
    t.string   "payment_status",   limit: 255, default: "pending"
    t.text     "last_error"
    t.string   "stripe_charge_id", limit: 255
    t.integer  "contest_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "credit_card_id"
    t.integer  "amount_cents"
    t.integer  "promotion_cents"
  end

  add_index "client_payments", ["client_id"], name: "index_client_payments_on_client_id", using: :btree
  add_index "client_payments", ["contest_id"], name: "index_client_payments_on_contest_id", using: :btree
  add_index "client_payments", ["credit_card_id"], name: "index_client_payments_on_credit_card_id", using: :btree

  create_table "clients", force: :cascade do |t|
    t.text     "first_name"
    t.text     "last_name"
    t.text     "email"
    t.string   "password",                      limit: 255
    t.text     "address"
    t.text     "state"
    t.integer  "zip"
    t.integer  "status",                                    default: 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "designer_level_id"
    t.text     "city"
    t.text     "phone_number"
    t.string   "plain_password",                limit: 255
    t.string   "stripe_customer_id",            limit: 255
    t.integer  "facebook_user_id",              limit: 8
    t.integer  "primary_card_id"
    t.boolean  "email_opt_in",                              default: true
    t.datetime "first_contest_created_at"
    t.datetime "latest_contest_created_at"
    t.datetime "last_log_in_at"
    t.string   "last_log_in_ip"
    t.datetime "last_remind_about_feedback_at"
    t.datetime "last_activity_at"
    t.boolean  "notified_owner",                            default: false, null: false
  end

  add_index "clients", ["email"], name: "index_clients_on_email", unique: true, using: :btree

  create_table "clients_promocodes", id: false, force: :cascade do |t|
    t.integer "promocode_id", null: false
    t.integer "client_id",    null: false
  end

  add_index "clients_promocodes", ["client_id", "promocode_id"], name: "index_clients_promocodes_on_client_id_and_promocode_id", using: :btree
  add_index "clients_promocodes", ["promocode_id", "client_id"], name: "index_clients_promocodes_on_promocode_id_and_client_id", using: :btree

  create_table "concept_board_comment_attachments", force: :cascade do |t|
    t.integer  "comment_id"
    t.integer  "attachment_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "concept_board_comment_attachments", ["comment_id", "attachment_id"], name: "comments_and_attachments", unique: true, using: :btree

  create_table "concept_board_comments", force: :cascade do |t|
    t.integer  "user_id"
    t.text     "text"
    t.integer  "contest_request_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "role",               limit: 255
    t.integer  "contest_note_id"
  end

  create_table "contest_notes", force: :cascade do |t|
    t.text     "text"
    t.integer  "contest_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "designer_id"
    t.integer  "client_id"
  end

  add_index "contest_notes", ["contest_id"], name: "index_contest_notes_on_contest_id", using: :btree

  create_table "contest_requests", force: :cascade do |t|
    t.integer  "designer_id"
    t.integer  "contest_id"
    t.text     "designs"
    t.text     "feedback"
    t.string   "status",                  limit: 255, default: "draft"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lookbook_id"
    t.string   "answer",                  limit: 255
    t.text     "final_note"
    t.text     "pull_together_note"
    t.string   "token",                   limit: 255
    t.datetime "submitted_at"
    t.datetime "won_at"
    t.datetime "last_visit_by_client_at"
    t.string   "email_thread_id",                                       null: false
  end

  add_index "contest_requests", ["contest_id", "designer_id"], name: "index_contest_requests_on_contest_id_and_designer_id", unique: true, using: :btree

  create_table "contests", force: :cascade do |t|
    t.text     "desirable_colors"
    t.text     "undesirable_colors"
    t.string   "space_budget",                          limit: 255
    t.text     "feedback"
    t.text     "project_name"
    t.integer  "budget_plan"
    t.integer  "client_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "space_length",                                      precision: 10, scale: 2, default: 0.0
    t.decimal  "space_width",                                       precision: 10, scale: 2, default: 0.0
    t.decimal  "space_height",                                      precision: 10, scale: 2
    t.integer  "design_category_id"
    t.integer  "design_space_id"
    t.string   "status",                                                                     default: "incomplete"
    t.datetime "phase_end"
    t.string   "theme",                                 limit: 255
    t.string   "space",                                 limit: 255
    t.string   "accessories",                           limit: 255
    t.string   "space_changes",                         limit: 255
    t.string   "shop",                                  limit: 255
    t.string   "accommodate_children",                  limit: 255
    t.string   "accommodate_pets",                      limit: 255
    t.text     "retailer"
    t.text     "elements_to_avoid"
    t.integer  "entertaining"
    t.integer  "durability"
    t.integer  "preferred_retailers_id"
    t.boolean  "designers_explore_other_colors",                                             default: false
    t.boolean  "designers_only_use_these_colors",                                            default: false
    t.datetime "finished_at"
    t.datetime "submission_started_at"
    t.boolean  "was_in_brief_pending_state"
    t.boolean  "notified_client_contest_not_yet_live",                                       default: false
    t.boolean  "ever_received_published_product_items"
    t.string   "location_zip"
    t.integer  "designer_level_id"
  end

  create_table "contests_appeals", force: :cascade do |t|
    t.integer "contest_id"
    t.integer "appeal_id"
    t.text    "reason"
    t.integer "value"
  end

  add_index "contests_appeals", ["appeal_id", "contest_id"], name: "index_contests_appeals_on_appeal_id_and_contest_id", using: :btree
  add_index "contests_appeals", ["contest_id", "appeal_id"], name: "index_contests_appeals_on_contest_id_and_appeal_id", using: :btree

  create_table "contests_design_spaces", id: false, force: :cascade do |t|
    t.integer "contest_id"
    t.integer "design_space_id"
  end

  add_index "contests_design_spaces", ["contest_id", "design_space_id"], name: "contests_on_design_spaces", unique: true, using: :btree
  add_index "contests_design_spaces", ["contest_id"], name: "index_contests_design_spaces_on_contest_id", using: :btree
  add_index "contests_design_spaces", ["design_space_id"], name: "index_contests_design_spaces_on_design_space_id", using: :btree

  create_table "contests_promocodes", force: :cascade do |t|
    t.integer  "contest_id",   null: false
    t.integer  "promocode_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "contests_promocodes", ["contest_id", "promocode_id"], name: "index_contests_promocodes_on_contest_id_and_promocode_id", unique: true, using: :btree

  create_table "credit_cards", force: :cascade do |t|
    t.integer  "client_id"
    t.text     "name_on_card"
    t.string   "card_type",          limit: 255
    t.text     "address"
    t.string   "state",              limit: 255
    t.string   "zip",                limit: 255
    t.text     "city"
    t.integer  "cvc"
    t.integer  "ex_month"
    t.integer  "ex_year"
    t.integer  "last_4_digits"
    t.string   "stripe_card_status", limit: 255, default: "pending"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "stripe_id",          limit: 255
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",                       default: 0, null: false
    t.integer  "attempts",                       default: 0, null: false
    t.text     "handler",                                    null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",          limit: 255
    t.string   "queue",              limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "contest_id"
    t.string   "image_type",         limit: 255
    t.integer  "contest_request_id"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "design_categories", force: :cascade do |t|
    t.text     "name"
    t.integer  "pos"
    t.integer  "price"
    t.integer  "status",     default: 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "design_spaces", force: :cascade do |t|
    t.text     "name"
    t.integer  "pos"
    t.integer  "parent_id"
    t.integer  "status",     default: 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "designer_levels", force: :cascade do |t|
    t.integer "level"
    t.text    "name"
  end

  create_table "designers", force: :cascade do |t|
    t.text     "first_name"
    t.text     "last_name"
    t.text     "email"
    t.string   "password",                limit: 255
    t.text     "zip"
    t.text     "ex_links"
    t.text     "ex_document_ids"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "portfolio_background_id"
    t.text     "portfolio_path"
    t.text     "phone_number"
    t.text     "plain_password"
    t.string   "state",                   limit: 255
    t.text     "address"
    t.text     "city"
    t.boolean  "active",                              default: true
    t.integer  "facebook_user_id",        limit: 8
    t.datetime "last_log_in_at"
    t.string   "last_log_in_ip"
    t.boolean  "paid_for_concept_boards",             default: false
    t.text     "blog_account_json"
    t.string   "blog_password"
    t.string   "blog_username"
  end

  add_index "designers", ["email"], name: "index_designers_on_email", unique: true, using: :btree

  create_table "example_links", force: :cascade do |t|
    t.text     "url"
    t.integer  "portfolio_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "final_notes", force: :cascade do |t|
    t.text     "text"
    t.integer  "designer_notification_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "contest_request_id",       null: false
    t.integer  "author_id",                null: false
    t.string   "author_role",              null: false
  end

  create_table "giftcard_payments", force: :cascade do |t|
    t.string   "stripe_charge_id"
    t.integer  "price_cents"
    t.integer  "quantity"
    t.text     "email"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.string   "first_name"
    t.string   "last_name"
    t.string   "brokerage"
    t.string   "phone"
  end

  create_table "image_items", force: :cascade do |t|
    t.text     "name"
    t.integer  "contest_request_id"
    t.integer  "image_id"
    t.text     "text"
    t.text     "brand"
    t.text     "link"
    t.string   "mark",                 limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "kind",                 limit: 255
    t.text     "dimensions"
    t.boolean  "final",                            default: false
    t.integer  "price_cents"
    t.string   "price_currency",       limit: 255, default: "USD",           null: false
    t.text     "price"
    t.integer  "temporary_version_id"
    t.string   "status",               limit: 255, default: "temporary"
    t.string   "phase",                limit: 255, default: "collaboration"
  end

  add_index "image_items", ["final", "phase", "temporary_version_id"], name: "index_image_items_on_final_and_phase_and_temporary_version_id", unique: true, using: :btree
  add_index "image_items", ["temporary_version_id"], name: "index_image_items_on_temporary_version_id", using: :btree

  create_table "image_links", force: :cascade do |t|
    t.integer "contest_id"
    t.text    "url"
  end

  create_table "images", force: :cascade do |t|
    t.string   "image",              limit: 255
    t.string   "image_file_name",    limit: 255
    t.string   "image_content_type", limit: 255
    t.string   "image_file_size",    limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "contest_id"
    t.string   "kind",               limit: 255
    t.integer  "designer_id"
    t.integer  "portfolio_id"
    t.string   "uploader_role",      limit: 255
    t.integer  "uploader_id"
    t.string   "file_type",                      default: "image"
    t.boolean  "image_processing"
  end

  create_table "inbound_emails", force: :cascade do |t|
    t.text     "json_content"
    t.boolean  "processed"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "lookbook_details", force: :cascade do |t|
    t.integer  "lookbook_id"
    t.integer  "image_id"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "phase",       limit: 255
  end

  create_table "lookbooks", force: :cascade do |t|
    t.integer  "contest_id"
    t.text     "feedback"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "outbound_emails", force: :cascade do |t|
    t.string   "mailer_method",          limit: 255
    t.text     "mail_args"
    t.string   "status",                 limit: 255, default: "not yet sent"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "sent_to_mail_server_at"
    t.text     "api_response"
    t.text     "plain_message"
    t.string   "template_name"
    t.text     "recipients"
  end

  create_table "portfolio_awards", force: :cascade do |t|
    t.integer  "portfolio_id"
    t.text     "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "portfolios", force: :cascade do |t|
    t.integer  "background_id"
    t.integer  "designer_id",                             null: false
    t.integer  "years_of_experience"
    t.boolean  "education_gifted"
    t.boolean  "education_school"
    t.boolean  "education_apprenticed"
    t.text     "school_name"
    t.text     "degree"
    t.text     "awards"
    t.text     "style_description"
    t.text     "about"
    t.text     "path"
    t.boolean  "modern_style",            default: false
    t.boolean  "vintage_style",           default: false
    t.boolean  "traditional_style",       default: false
    t.boolean  "contemporary_style",      default: false
    t.boolean  "coastal_style",           default: false
    t.boolean  "global_style",            default: false
    t.boolean  "eclectic_style",          default: false
    t.boolean  "hollywood_glam_style",    default: false
    t.boolean  "midcentury_modern_style", default: false
    t.boolean  "transitional_style",      default: false
    t.boolean  "rustic_elegance_style",   default: false
    t.boolean  "color_pop_style",         default: false
    t.float    "cover_x_percents_offset"
    t.float    "cover_y_percents_offset"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "preferred_retailers", force: :cascade do |t|
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

  create_table "promocodes", force: :cascade do |t|
    t.text     "promocode"
    t.text     "display_message"
    t.boolean  "active",                        default: true
    t.integer  "discount_cents",                default: 0,     null: false
    t.string   "discount_currency", limit: 255, default: "USD", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "one_time",                      default: true
  end

  create_table "realtor_contacts", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "brokerage"
    t.string   "email"
    t.string   "phone"
    t.string   "choice"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "realtor_contacts", ["email"], name: "index_realtor_contacts_on_email", unique: true, using: :btree

  create_table "reviewer_feedbacks", force: :cascade do |t|
    t.text     "text"
    t.integer  "invitation_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "reviewer_feedbacks", ["invitation_id"], name: "index_reviewer_feedbacks_on_invitation_id", using: :btree

  create_table "reviewer_invitations", force: :cascade do |t|
    t.text     "username"
    t.text     "email"
    t.integer  "contest_id"
    t.text     "url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "reviewer_invitations", ["contest_id"], name: "index_reviewer_invitations_on_contest_id", using: :btree

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", limit: 255, null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", unique: true, using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "sounds", force: :cascade do |t|
    t.integer  "contest_request_id"
    t.string   "audio_file_name",    limit: 255
    t.string   "audio_content_type", limit: 255
    t.integer  "audio_file_size"
    t.datetime "audio_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_notifications", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "type",                     limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "contest_id"
    t.integer  "contest_request_id"
    t.boolean  "read",                                 default: false
    t.integer  "contest_comment_id"
    t.integer  "concept_board_comment_id"
    t.integer  "final_note_id"
  end

  add_index "user_notifications", ["contest_id"], name: "index_user_notifications_on_contest_id", using: :btree
  add_index "user_notifications", ["user_id"], name: "index_user_notifications_on_user_id", using: :btree

  add_foreign_key "contests_design_spaces", "contests"
  add_foreign_key "contests_design_spaces", "design_spaces"
end
