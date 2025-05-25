# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2025_05_20_092427) do
  create_table "allowed_students", force: :cascade do |t|
    t.string "name"
    t.string "surname"
    t.string "student_number"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "group_memberships", force: :cascade do |t|
    t.integer "group_id"
    t.integer "student_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "groups", force: :cascade do |t|
    t.string "name"
    t.integer "leader_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "project_id"
    t.index ["project_id"], name: "index_groups_on_project_id"
  end

  create_table "project_applications", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "project_id", null: false
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_project_applications_on_project_id"
    t.index ["user_id"], name: "index_project_applications_on_user_id"
  end

  create_table "project_proposals", force: :cascade do |t|
    t.integer "group_id", null: false
    t.integer "advisor_id", null: false
    t.string "title", null: false
    t.text "description", null: false
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "project_id"
  end

  create_table "project_requests", force: :cascade do |t|
    t.integer "group_id"
    t.integer "project_id"
    t.text "motivation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "advisor_id"
    t.integer "status", default: 0
  end

  create_table "projects", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "advisor_id", null: false
    t.boolean "published", default: false
    t.integer "quota", default: 0
    t.index ["advisor_id"], name: "index_projects_on_advisor_id"
  end

  create_table "system_settings", force: :cascade do |t|
    t.boolean "students_can_login", default: true
    t.boolean "students_can_register", default: true
    t.datetime "group_creation_deadline"
    t.datetime "project_submission_deadline"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "key"
    t.string "value"
    t.integer "group_quota"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "role", default: 0
    t.string "first_name"
    t.string "last_name"
    t.string "student_number"
    t.boolean "must_change_password", default: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "groups", "projects"
  add_foreign_key "project_applications", "projects"
  add_foreign_key "project_applications", "users"
  add_foreign_key "project_proposals", "groups"
  add_foreign_key "project_proposals", "projects"
  add_foreign_key "project_proposals", "users", column: "advisor_id"
end
