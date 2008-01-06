class CurrentPlayer < ActiveRecord::Base
  validates_presence_of :bz_server_id, :callsign
  belongs_to :bz_server
end
