class CreateProductAliases < ActiveRecord::Migration[7.0]
  def change
    create_table :product_aliases do |t|
      t.string :name, null: false
      t.references :product, null: false, foreign_key: true

      t.timestamps
    end
    add_index :product_aliases, :name, unique: true
  end
end
