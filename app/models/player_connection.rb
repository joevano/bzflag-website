class PlayerConnection < ActiveRecord::Base
  belongs_to :email
  belongs_to :bz_server
  belongs_to :callsign
  belongs_to :ip
end
