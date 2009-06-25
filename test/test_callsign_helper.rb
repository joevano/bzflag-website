# Expose the @@callsign hash length for testing
class Callsign
  def self.cache_length
    @@callsigns.length
  end

  def self.clear_cache
    @@callsigns = Hash.new
  end
end

