class Callsign < ActiveRecord::Base
  validates_presence_of :callsign
  belongs_to :current_players

  def self.locate(name)
    Callsign.find_by_callsign(name) || Callsign.create(:callsign => name)
  end
end
