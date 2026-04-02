Yabeda.configure do
  gauge :process_resident_memory_bytes,
    comment: "Resident memory size in bytes",
    aggregation: :most_recent

  collect do
    rss_pages = File.read("/proc/self/statm").split[1].to_i
    process_resident_memory_bytes.set({}, rss_pages * 4096)
  end
end

Yabeda::Rails.install!
