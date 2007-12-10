class Callsign < ActiveRecord::Base
  validates_presence_of :callsign
  belongs_to :player_connection

  def self.locate(name)
    Callsign.find_by_callsign(name) || Callsign.create(:callsign => name)
  end
end
