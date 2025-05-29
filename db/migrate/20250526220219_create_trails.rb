class CreateTrails < ActiveRecord::Migration[7.2]
  def change
    create_table :trails do |t|
      t.string :name, null: false
      t.string :difficulty, null: false
      t.line_string :path, geographic: true, srid: 4326
      t.bigint :osm_id, null: false, index: { unique: true }
      t.timestamps
    end

    add_check_constraint :trails, "difficulty IN ('easy', 'moderate', 'difficult', 'unknown')", name: "difficulty_check"
    add_index :trails, :name
    add_index :trails, :difficulty
  end
end
# SRID 4326 = WGS84 standard for GPS
# OSM ID uniqueness prevents duplicate imports
