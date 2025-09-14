module DashboardHelper
  def coverage_status(coverage)
    case coverage
    when 90..100 then "excellent"
    when 70..89 then "good"
    else "needs-improvement"
    end
  end

  def coverage_color(coverage)
    case coverage
    when 90..100 then "green"
    when 70..89 then "orange"
    else "red"
    end
  end
end
