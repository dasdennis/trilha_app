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

ActiveRecord::Schema[7.2].define(version: 2025_05_26_220219) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"

  create_table "trails", force: :cascade do |t|
    t.string "name", null: false
    t.string "difficulty", null: false
    t.geography "path", limit: {:srid=>4326, :type=>"line_string", :geographic=>true}
    t.bigint "osm_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["difficulty"], name: "index_trails_on_difficulty"
    t.index ["name"], name: "index_trails_on_name"
    t.index ["osm_id"], name: "index_trails_on_osm_id", unique: true
    t.check_constraint "difficulty::text = ANY (ARRAY['easy'::character varying, 'moderate'::character varying, 'difficult'::character varying, 'unknown'::character varying]::text[])", name: "difficulty_check"
  end
end
