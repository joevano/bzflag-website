class BzServerAddPlayerCount < ActiveRecord::Migration
  def self.up
    add_column :bz_servers, :current_player_count, :integer
  end

  def self.down
    remove_column :bz_servers, :current_player_count
  end
end
