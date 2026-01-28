# Controlled via config.rack_attack_enabled (defaults to true)
Rack::Attack.enabled = Rails.configuration.rack_attack_enabled

class Rack::Attack
  # Use memory store (no DB writes, resets on restart)
  cache.store = ActiveSupport::Cache::MemoryStore.new

  # Custom response for throttled requests
  self.throttled_responder = lambda do |request|
    if request.path.start_with?("/api/")
      [429, {"Content-Type" => "application/json"}, [{error: "Rate limit exceeded"}.to_json]]
    else
      [429, {"Content-Type" => "text/plain"}, ["Retry later\n"]]
    end
  end

  # Throttle login: 5 requests per 20 seconds per IP
  throttle("logins/ip", limit: 5, period: 20.seconds) do |req|
    req.ip if req.path == "/login" && req.post?
  end

  # Throttle API: 10 requests per minute per API key
  throttle("api/key", limit: 10, period: 1.minute) do |req|
    if req.path.start_with?("/api/")
      req.get_header("HTTP_AUTHORIZATION")&.sub(/^Bearer\s+/, "")
    end
  end
end
