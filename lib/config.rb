class Config
  def self.get
    file = File.read("config/config.json")
    JSON.parse(file)
  end
end

