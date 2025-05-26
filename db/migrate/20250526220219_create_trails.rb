class CreateTrails < ActiveRecord::Migration[7.2]
  def change
    create_table :trails do |t|
      t.string :name
      t.string :difficulty

      t.timestamps
    end
  end
end
