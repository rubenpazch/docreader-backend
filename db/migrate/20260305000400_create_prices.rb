class CreatePrices < ActiveRecord::Migration[7.0]
  def change
    create_table :prices do |t|
      t.references :product, null: false, foreign_key: true
      t.references :brand, null: false, foreign_key: true
      t.references :quality, null: false, foreign_key: true
      t.decimal :value, null: false, precision: 10, scale: 2
      t.string :unit
      t.integer :unit_quantity
      t.date :date
      t.timestamps
    end
    add_index :prices, [:product_id, :brand_id, :quality_id, :unit, :unit_quantity, :date], name: 'index_prices_on_product_brand_quality_unit_date'
  end
end
