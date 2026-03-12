require 'benchmark'
require 'csv'
require 'fileutils'
require 'time'

namespace :perf do
  desc 'Seed a large product catalog for performance testing. Usage: rake perf:seed_catalog[50000,1,2]'
  task :seed_catalog, [:count, :aliases_per_product, :prices_per_product] => :environment do |_task, args|
    count = (args[:count] || ENV['COUNT'] || 50_000).to_i
    aliases_per_product = (args[:aliases_per_product] || ENV['ALIASES_PER_PRODUCT'] || 1).to_i
    prices_per_product = (args[:prices_per_product] || ENV['PRICES_PER_PRODUCT'] || 2).to_i

    quality = Quality.find_or_create_by!(level: 'perf-standard') do |q|
      q.description = 'Performance benchmark quality'
      q.quality_factor = 1.0
    end

    brands = Array.new([prices_per_product, 3].max) do |idx|
      Brand.find_or_create_by!(name: "PerfBrand#{idx + 1}")
    end

    now = Time.current
    existing = Product.where("normalized_name LIKE 'perf-product-%'").count
    start_index = existing + 1

    puts "Seeding #{count} products starting at index #{start_index}..."

    product_rows = []
    count.times do |offset|
      n = start_index + offset
      product_rows << {
        name: "Perf Product #{n}",
        normalized_name: "perf-product-#{n}",
        description: "producto perf categoria utiles #{n}",
        category: 'utiles',
        created_at: now,
        updated_at: now
      }
    end

    Product.insert_all(product_rows)

    inserted = Product.where(normalized_name: product_rows.map { |r| r[:normalized_name] })

    alias_rows = []
    price_rows = []

    inserted.find_each do |product|
      aliases_per_product.times do |i|
        alias_rows << {
          product_id: product.id,
          name: "#{product.name} alias #{i + 1}",
          created_at: now,
          updated_at: now
        }
      end

      prices_per_product.times do |i|
        brand = brands[i % brands.length]
        price_rows << {
          product_id: product.id,
          brand_id: brand.id,
          quality_id: quality.id,
          value: (4.0 + i + rand * 5).round(2),
          unit: 'unidad',
          unit_quantity: 1,
          date: Date.current,
          created_at: now,
          updated_at: now
        }
      end
    end

    ProductAlias.insert_all(alias_rows) if alias_rows.any?
    Price.insert_all(price_rows) if price_rows.any?

    puts "Done. Products inserted: #{inserted.count}, aliases: #{alias_rows.size}, prices: #{price_rows.size}."
  end

  desc 'Benchmark ProductMatcherService and print p50/p95/p99. Usage: rake perf:benchmark_matcher["cuaderno 100 hojas",30]'
  task :benchmark_matcher, [:query, :iterations] => :environment do |_task, args|
    query = (args[:query] || ENV['QUERY'] || 'perf product 1000').to_s
    iterations = (args[:iterations] || ENV['ITERATIONS'] || 30).to_i

    item = {
      descripcion: query,
      cantidad: 1,
      atributos: {}
    }

    durations_ms = []
    iterations.times do
      elapsed = Benchmark.realtime { ProductMatcherService.new(item).call }
      durations_ms << (elapsed * 1000.0)
    end

    puts "Matcher benchmark for query: #{query.inspect}"
    stats = compute_stats(durations_ms)
    print_stats(stats)
    append_csv_row('matcher',
                   {
                     query: query,
                     iterations: iterations,
                     catalog_products: Product.count,
                     catalog_prices: Price.count
                   },
                   stats)
  end

  desc 'Benchmark BudgetProposalService and print p50/p95/p99. Usage: rake perf:benchmark_proposal[20,10]'
  task :benchmark_proposal, [:items_count, :iterations] => :environment do |_task, args|
    items_count = (args[:items_count] || ENV['ITEMS_COUNT'] || 20).to_i
    iterations = (args[:iterations] || ENV['ITERATIONS'] || 10).to_i

    sample_products = Product.order('RANDOM()').limit(items_count).pluck(:name)
    if sample_products.empty?
      puts 'No products found. Seed data first with rake perf:seed_catalog.'
      next
    end

    items = sample_products.map do |name|
      { descripcion: name, cantidad: 1, atributos: {} }
    end

    durations_ms = []
    iterations.times do
      elapsed = Benchmark.realtime { BudgetProposalService.new(items).call }
      durations_ms << (elapsed * 1000.0)
    end

    puts "Proposal benchmark with #{items_count} items"
    stats = compute_stats(durations_ms)
    print_stats(stats)
    append_csv_row('proposal',
                   {
                     items_count: items_count,
                     iterations: iterations,
                     catalog_products: Product.count,
                     catalog_prices: Price.count
                   },
                   stats)
  end

  def compute_stats(values_ms)
    sorted = values_ms.sort
    count = sorted.length

    {
      count: count,
      avg: sorted.sum / count,
      p50: percentile(sorted, 0.50),
      p95: percentile(sorted, 0.95),
      p99: percentile(sorted, 0.99),
      min: sorted.first,
      max: sorted.last
    }
  end

  def print_stats(stats)
    puts format('runs=%<count>d avg=%<avg>.2fms p50=%<p50>.2fms p95=%<p95>.2fms p99=%<p99>.2fms min=%<min>.2fms max=%<max>.2fms',
                count: stats[:count],
                avg: stats[:avg],
                p50: stats[:p50],
                p95: stats[:p95],
                p99: stats[:p99],
                min: stats[:min],
                max: stats[:max])
  end

  def append_csv_row(benchmark_name, context, stats)
    report_path = ENV['PERF_REPORT_PATH']
    return if report_path.to_s.strip.empty?

    FileUtils.mkdir_p(File.dirname(report_path))
    write_headers = !File.exist?(report_path)

    CSV.open(report_path, 'ab') do |csv|
      if write_headers
        csv << %w[timestamp benchmark query items_count iterations catalog_products catalog_prices runs avg_ms p50_ms p95_ms p99_ms min_ms max_ms]
      end

      csv << [
        Time.current.iso8601,
        benchmark_name,
        context[:query],
        context[:items_count],
        context[:iterations],
        context[:catalog_products],
        context[:catalog_prices],
        stats[:count],
        stats[:avg].round(4),
        stats[:p50].round(4),
        stats[:p95].round(4),
        stats[:p99].round(4),
        stats[:min].round(4),
        stats[:max].round(4)
      ]
    end

    puts "CSV report appended to #{report_path}"
  end

  def percentile(sorted_values, p)
    return 0.0 if sorted_values.empty?

    rank = (p * (sorted_values.length - 1)).round
    sorted_values[rank]
  end
end