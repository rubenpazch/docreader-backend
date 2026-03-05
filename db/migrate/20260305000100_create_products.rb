class CreateProducts < ActiveRecord::Migration[7.0]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.string :normalized_name, null: false
      t.text :description
      t.string :category
      t.timestamps
    end
    add_index :products, :normalized_name, unique: true
  end
end
