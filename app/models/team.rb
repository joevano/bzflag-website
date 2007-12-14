class Team < ActiveRecord::Base
  has_many :player_connections

  def self.locate(name)
    Team.find_by_name(name) || Team.create(:name => name)
  end
end
