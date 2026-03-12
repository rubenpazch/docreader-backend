class AddPublicUuidAndPerformanceIndexes < ActiveRecord::Migration[7.0]
  TABLES_WITH_UUID = %i[products brands qualities prices product_aliases documents].freeze

  def up
    TABLES_WITH_UUID.each do |table|
      add_column table, :public_uuid, :string
    end

    backfill_public_uuids

    TABLES_WITH_UUID.each do |table|
      change_column_null table, :public_uuid, false
      add_index table, :public_uuid, unique: true
    end

    add_index :products, :category unless index_exists?(:products, :category)
    add_index :product_aliases, [:product_id, :name], name: 'index_product_aliases_on_product_id_and_name' unless index_exists?(:product_aliases, [:product_id, :name], name: 'index_product_aliases_on_product_id_and_name')
    add_index :prices, [:product_id, :value], name: 'index_prices_on_product_id_and_value' unless index_exists?(:prices, [:product_id, :value], name: 'index_prices_on_product_id_and_value')
    add_index :prices, [:product_id, :date], name: 'index_prices_on_product_id_and_date' unless index_exists?(:prices, [:product_id, :date], name: 'index_prices_on_product_id_and_date')
    add_index :documents, :created_at unless index_exists?(:documents, :created_at)
  end

  def down
    remove_index :documents, :created_at if index_exists?(:documents, :created_at)
    remove_index :prices, name: 'index_prices_on_product_id_and_date' if index_exists?(:prices, [:product_id, :date], name: 'index_prices_on_product_id_and_date')
    remove_index :prices, name: 'index_prices_on_product_id_and_value' if index_exists?(:prices, [:product_id, :value], name: 'index_prices_on_product_id_and_value')
    remove_index :product_aliases, name: 'index_product_aliases_on_product_id_and_name' if index_exists?(:product_aliases, [:product_id, :name], name: 'index_product_aliases_on_product_id_and_name')
    remove_index :products, :category if index_exists?(:products, :category)

    TABLES_WITH_UUID.each do |table|
      remove_index table, :public_uuid if index_exists?(table, :public_uuid)
      remove_column table, :public_uuid if column_exists?(table, :public_uuid)
    end
  end

  private

  def backfill_public_uuids
    product_model = Class.new(ActiveRecord::Base) { self.table_name = 'products' }
    brand_model = Class.new(ActiveRecord::Base) { self.table_name = 'brands' }
    quality_model = Class.new(ActiveRecord::Base) { self.table_name = 'qualities' }
    price_model = Class.new(ActiveRecord::Base) { self.table_name = 'prices' }
    alias_model = Class.new(ActiveRecord::Base) { self.table_name = 'product_aliases' }
    document_model = Class.new(ActiveRecord::Base) { self.table_name = 'documents' }

    [product_model, brand_model, quality_model, price_model, alias_model, document_model].each do |model|
      model.reset_column_information
      model.find_each do |record|
        record.update_columns(public_uuid: SecureRandom.uuid)
      end
    end
  end
end
