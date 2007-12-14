class PlayerConnectionAddTeam < ActiveRecord::Migration
  def self.up
    add_column :player_connections, :team_id, :integer
  end

  def self.down
    remove_column :player_connections, :team_id
  end
end
