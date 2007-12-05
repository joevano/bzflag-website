class Callsign < ActiveRecord::Base
  validates_existence_of :callsign
  belongs_to :current_players
end
