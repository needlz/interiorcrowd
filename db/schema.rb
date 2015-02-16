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

ActiveRecord::Schema.define(version: 20150216151747) do

  create_table "appeals", force: true do |t|
    t.string "image"
    t.string "first_name"
    t.string "second_name"
  end

  create_table "beta_subscribers", force: true do |t|
    t.text     "email"
    t.string   "role"
    t.text     "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "clients", force: true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "password"
    t.string   "name_on_card"
    t.string   "card_type"
    t.string   "address"
    t.string   "state"
    t.integer  "zip"
    t.string   "card_number"
    t.integer  "card_ex_month"
    t.integer  "card_ex_year"
    t.integer  "card_cvc"
    t.integer  "status",            default: 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "designer_level_id"
    t.string   "city"
    t.string   "phone_number"
    t.string   "billing_address"
    t.string   "billing_state"
    t.integer  "billing_zip"
    t.string   "billing_city"
  end

  create_table "concept_board_comments", force: true do |t|
    t.integer  "user_id"
    t.text     "text"
    t.integer  "contest_request_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "role"
    t.boolean  "read",               default: false
  end

  create_table "contest_notes", force: true do |t|
    t.text     "text"
    t.integer  "contest_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "contest_notes", ["contest_id"], name: "index_contest_notes_on_contest_id", using: :btree

  create_table "contest_requests", force: true do |t|
    t.integer  "designer_id"
    t.integer  "contest_id"
    t.text     "designs"
    t.text     "feedback"
    t.string   "status",      default: "draft"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lookbook_id"
    t.string   "answer"
  end

  create_table "contests", force: true do |t|
    t.string   "desirable_colors"
    t.string   "undesirable_colors"
    t.integer  "space_budget"
    t.text     "feedback"
    t.string   "project_name"
    t.integer  "budget_plan"
    t.integer  "client_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "space_length",           precision: 10, scale: 2, default: 0.0
    t.decimal  "space_width",            precision: 10, scale: 2, default: 0.0
    t.decimal  "space_height",           precision: 10, scale: 2
    t.integer  "design_category_id"
    t.integer  "design_space_id"
    t.string   "status",                                          default: "submission"
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
  end

  create_table "contests_appeals", force: true do |t|
    t.integer "contest_id"
    t.integer "appeal_id"
    t.text    "reason"
    t.integer "value"
  end

  add_index "contests_appeals", ["appeal_id", "contest_id"], name: "index_contests_appeals_on_appeal_id_and_contest_id", using: :btree
  add_index "contests_appeals", ["contest_id", "appeal_id"], name: "index_contests_appeals_on_contest_id_and_appeal_id", using: :btree

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "contest_id"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "design_categories", force: true do |t|
    t.string   "name"
    t.integer  "pos"
    t.integer  "price"
    t.integer  "status",         default: 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "before_picture"
    t.string   "after_picture"
  end

  create_table "design_spaces", force: true do |t|
    t.string   "name"
    t.integer  "pos"
    t.integer  "parent_id"
    t.integer  "status",     default: 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "designer_levels", force: true do |t|
    t.integer "level"
    t.string  "name"
    t.string  "image"
  end

  create_table "designers", force: true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "password"
    t.string   "zip"
    t.string   "ex_links"
    t.string   "ex_document_ids"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "portfolio_background_id"
    t.string   "portfolio_path"
    t.string   "phone_number"
  end

  create_table "example_links", force: true do |t|
    t.string   "url"
    t.integer  "portfolio_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "image_links", force: true do |t|
    t.integer "contest_id"
    t.string  "url"
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
  end

  create_table "lookbook_details", force: true do |t|
    t.integer  "lookbook_id"
    t.integer  "image_id"
    t.text     "description"
    t.string   "url"
    t.integer  "doc_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "lookbooks", force: true do |t|
    t.integer  "contest_id"
    t.text     "feedback"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "portfolio_awards", force: true do |t|
    t.integer  "portfolio_id"
    t.text     "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "portfolios", force: true do |t|
    t.integer "background_id"
    t.integer "designer_id",                             null: false
    t.integer "years_of_experience"
    t.boolean "education_gifted"
    t.boolean "education_school"
    t.boolean "education_apprenticed"
    t.string  "school_name"
    t.string  "degree"
    t.text    "awards"
    t.text    "style_description"
    t.text    "about"
    t.string  "path"
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

  create_table "reviewer_feedbacks", force: true do |t|
    t.text     "text"
    t.integer  "invitation_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "reviewer_feedbacks", ["invitation_id"], name: "index_reviewer_feedbacks_on_invitation_id", using: :btree

  create_table "reviewer_invitations", force: true do |t|
    t.string   "username"
    t.string   "email"
    t.integer  "contest_id"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "reviewer_invitations", ["contest_id"], name: "index_reviewer_invitations_on_contest_id", using: :btree

  create_table "user_notifications", force: true do |t|
    t.integer  "user_id"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "contest_id"
    t.integer  "contest_request_id"
  end

  add_index "user_notifications", ["contest_id"], name: "index_user_notifications_on_contest_id", using: :btree
  add_index "user_notifications", ["user_id"], name: "index_user_notifications_on_user_id", using: :btree

end
