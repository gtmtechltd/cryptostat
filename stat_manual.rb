class StatManual
  def self.get config
    result = {}
    config.each do |k,v|
      next if k == "comment"
      result [ k ] = v unless v.tr("0.", "").empty?
    end
    result
  end
end
