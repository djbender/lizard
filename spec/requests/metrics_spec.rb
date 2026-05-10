require "rails_helper"

RSpec.describe "GET /metrics", type: :request do
  it "returns Prometheus exposition successfully" do
    get "/metrics"

    expect(response).to have_http_status(:ok)
    expect(response.content_type).to include("text/plain")
  end

  it "exposes DB pool gauges" do
    get "/metrics"

    expect(response.body).to include("rails_db_pool_size")
    expect(response.body).to include("rails_db_pool_busy")
    expect(response.body).to include("rails_db_pool_idle")
  end

  it "exposes Ruby GC and process gauges" do
    get "/metrics"

    expect(response.body).to include("ruby_gc_count")
    expect(response.body).to include("ruby_heap_live_slots")
    expect(response.body).to include("process_resident_memory_bytes")
  end

  it "bypasses site auth" do
    get "/metrics"

    expect(response).not_to redirect_to("/sign_in")
  end
end
