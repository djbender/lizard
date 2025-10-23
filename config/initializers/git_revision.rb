# Capture git SHA for version display
module GitRevision
  def self.sha
    @sha ||= begin
      revision_file = Rails.root.join("REVISION")
      if File.exist?(revision_file)
        File.read(revision_file).strip
      elsif ENV["GIT_REV"].present?
        ENV["GIT_REV"][0..7] # Use first 8 characters if full SHA provided
      else
        "dev"
      end
    rescue
      "unknown"
    end
  end
end
