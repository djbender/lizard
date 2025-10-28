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

ActiveRecord::Schema[8.1].define(version: 2025_09_14_071625) do
  create_table "projects", force: :cascade do |t|
    t.string "api_key"
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["api_key"], name: "index_projects_on_api_key", unique: true
  end

  create_table "test_runs", force: :cascade do |t|
    t.string "branch"
    t.string "commit_sha"
    t.float "coverage"
    t.datetime "created_at", null: false
    t.integer "js_specs"
    t.integer "project_id", null: false
    t.datetime "ran_at"
    t.integer "ruby_specs"
    t.float "runtime"
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_test_runs_on_project_id"
  end

  add_foreign_key "test_runs", "projects"
end
