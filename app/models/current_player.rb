class CurrentPlayer < ActiveRecord::Base
  validates_existence_of :bz_server_id, :callsign_id
  has_one :callsign
end
