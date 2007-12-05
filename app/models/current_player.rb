class CurrentPlayer < ActiveRecord::Base
  validates_presence_of :bz_server_id, :callsign_id
  has_one :callsign
  belongs_to :bz_server
end
