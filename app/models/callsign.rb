class Callsign < ActiveRecord::Base
  validates_presence_of :callsign
  has_many :player_connections
  has_many :ips, :through => :player_connections
  has_many :teams, :through => :player_connections

  def self.locate(name)
    Callsign.find_by_callsign(name) || Callsign.create(:callsign => name)
  end
end
