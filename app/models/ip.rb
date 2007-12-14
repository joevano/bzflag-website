class Ip < ActiveRecord::Base
  has_many :player_connections
  has_many :callsigns, :through => :player_connections

  def self.locate(ip)
    Ip.find_by_ip(ip) || Ip.create(:ip => ip)
  end
end
