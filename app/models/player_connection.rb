class PlayerConnection < ActiveRecord::Base
  has_one :email
  has_one :bz_server
  has_one :callsign
  has_one :ip
end
