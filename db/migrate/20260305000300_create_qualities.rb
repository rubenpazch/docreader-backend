class CreateQualities < ActiveRecord::Migration[7.0]
  def change
    create_table :qualities do |t|
      t.string :level, null: false
      t.text :description
      t.decimal :quality_factor, precision: 5, scale: 2
      t.timestamps
    end
    add_index :qualities, :level, unique: true
  end
end
