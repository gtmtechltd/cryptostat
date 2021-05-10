require_relative "./utils.rb"

class StatManual
  def self.get config
    name   = config["name"]
    Utils.info "Analysing manually entered coins..."
    result = {}
    config.each do |k,v|
      next if k == "comment" or k == "name"
      result [ k ] = v unless v.tr("0.", "").empty?
    end
    Utils.prepare_result( name, result )
  end
end
