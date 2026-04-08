Yabeda.configure do
  gauge :process_resident_memory_bytes,
    comment: "Resident memory size in bytes",
    aggregation: :most_recent

  # GC metrics
  gauge :ruby_gc_count,
    comment: "Total number of GC runs",
    aggregation: :most_recent
  gauge :ruby_gc_duration_seconds,
    comment: "Total time spent in GC (seconds, monotonic)",
    aggregation: :most_recent
  gauge :ruby_heap_live_slots,
    comment: "Number of live heap slots",
    aggregation: :most_recent
  gauge :ruby_heap_free_slots,
    comment: "Number of free heap slots",
    aggregation: :most_recent

  # DB connection pool metrics
  gauge :rails_db_pool_size,
    comment: "Max number of connections in the pool",
    aggregation: :most_recent
  gauge :rails_db_pool_connections,
    comment: "Current number of connections in the pool",
    aggregation: :most_recent
  gauge :rails_db_pool_busy,
    comment: "Number of busy connections",
    aggregation: :most_recent
  gauge :rails_db_pool_idle,
    comment: "Number of idle connections",
    aggregation: :most_recent
  gauge :rails_db_pool_waiting,
    comment: "Number of threads waiting for a connection",
    aggregation: :most_recent

  # Cache metrics
  counter :rails_cache_read_total,
    comment: "Total cache reads",
    tags: [:result]

  collect do
    # RSS
    rss_pages = File.read("/proc/self/statm").split[1].to_i
    process_resident_memory_bytes.set({}, rss_pages * 4096)

    # GC
    gc = GC.stat
    ruby_gc_count.set({}, gc[:count])
    ruby_gc_duration_seconds.set({}, GC.total_time / 1_000_000_000.0)
    ruby_heap_live_slots.set({}, gc[:heap_live_slots])
    ruby_heap_free_slots.set({}, gc[:heap_free_slots])

    # DB pool
    if defined?(ActiveRecord::Base) && ActiveRecord::Base.connected?
      pool_stat = ActiveRecord::Base.connection_pool.stat
      rails_db_pool_size.set({}, pool_stat[:size])
      rails_db_pool_connections.set({}, pool_stat[:connections])
      rails_db_pool_busy.set({}, pool_stat[:busy])
      rails_db_pool_idle.set({}, pool_stat[:idle])
      rails_db_pool_waiting.set({}, pool_stat[:waiting])
    end
  end
end

# Subscribe to cache reads for hit/miss tracking
ActiveSupport::Notifications.subscribe("cache_read.active_support") do |event|
  result = event.payload[:hit] ? "hit" : "miss"
  Yabeda.rails_cache_read_total.increment({result: result})
end

Yabeda::Rails.install!
