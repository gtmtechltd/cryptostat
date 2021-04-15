class StatManual
  def self.get config
    STDERR.puts "Analysing manually entered coins..."
    result = {}
    config.each do |k,v|
      next if k == "comment"
      result [ k ] = v unless v.tr("0.", "").empty?
    end
    result
  end
end
