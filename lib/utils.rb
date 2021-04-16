class Utils
  def self.debug message
    if ENV["CRYPTOSTAT_DEBUG"] == "true" then
      STDERR.puts message
    end
  end

  def self.info message
    STDERR.puts message
  end
end
