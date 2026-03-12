class AddPostgresTrigramIndexesForMatcher < ActiveRecord::Migration[7.0]
  def up
    return unless postgres?

    enable_extension 'pg_trgm' unless extension_enabled?('pg_trgm')

    execute <<~SQL
      CREATE INDEX IF NOT EXISTS index_products_on_lower_name_trgm
      ON products USING gin (LOWER(name) gin_trgm_ops);
    SQL

    execute <<~SQL
      CREATE INDEX IF NOT EXISTS index_products_on_lower_normalized_name_trgm
      ON products USING gin (LOWER(normalized_name) gin_trgm_ops);
    SQL

    execute <<~SQL
      CREATE INDEX IF NOT EXISTS index_products_on_lower_description_trgm
      ON products USING gin (LOWER(description) gin_trgm_ops);
    SQL

    execute <<~SQL
      CREATE INDEX IF NOT EXISTS index_products_on_lower_category_trgm
      ON products USING gin (LOWER(category) gin_trgm_ops);
    SQL

    execute <<~SQL
      CREATE INDEX IF NOT EXISTS index_product_aliases_on_lower_name_trgm
      ON product_aliases USING gin (LOWER(name) gin_trgm_ops);
    SQL
  end

  def down
    return unless postgres?

    execute 'DROP INDEX IF EXISTS index_product_aliases_on_lower_name_trgm;'
    execute 'DROP INDEX IF EXISTS index_products_on_lower_category_trgm;'
    execute 'DROP INDEX IF EXISTS index_products_on_lower_description_trgm;'
    execute 'DROP INDEX IF EXISTS index_products_on_lower_normalized_name_trgm;'
    execute 'DROP INDEX IF EXISTS index_products_on_lower_name_trgm;'
  end

  private

  def postgres?
    connection.adapter_name.downcase.include?('postgres')
  end
end
