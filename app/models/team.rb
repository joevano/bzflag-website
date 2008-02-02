class Team < ActiveRecord::Base
  has_many :player_connections
end
