module TestRunDecorator
  DEFAULTS = {
    ran_at: -> { Time.current },
    branch: -> { "unknown" },
    runtime: -> { 0.0 },
    ruby_specs: -> { 0 },
    js_specs: -> { 0 },
    coverage: -> { 0.0 },
    commit_sha: -> { "unknown" }
  }.freeze

  DEFAULTS.each do |method, default|
    define_method(method) do
      super() || default.call
    end
  end
end
