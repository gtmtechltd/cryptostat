class Utils
 
  @@data = {}

  def self.set k, v
    @@data[ k ] = v
  end

  def self.get k
    if @@data.key? k then
      return @@data[ k ]
    else
      return false
    end
  end
    
  def self.debug message
    if ENV["CRYPTOSTAT_DEBUG"] == "true" then
      STDERR.puts message
    end
  end

  def self.info message
    STDERR.puts message
  end

  def self.cacheok? file
    return false unless File.exist? "cache/#{file}.cache"
    text = File.read("cache/#{file}.cache")
    json = JSON.parse( text )
    cache_time = Time.now.to_i - json["time"]
    cache_time < 3600
  end

  def self.write_cache file, data
    self.info "-> Writing cache cache/#{file}.cache"
    File.open("cache/#{file}.cache", "w") { |f| f.write data.to_json }
  end

  def self.prepare_result name, data
    self.info "-> Writing history file history/#{_date}.#{name}.txt"
    File.open("history/#{_date}.#{name}.txt") { |f| f.write data.to_s }
    data
  end

  def self.read_cache file
    text = File.read("cache/#{file}.cache")
    json = JSON.parse( text )
    self.info "<- Reading from cache cache/#{file}.cache (#{Time.now.to_i - json["time"]}s old)"
    json["result"]
  end

end
