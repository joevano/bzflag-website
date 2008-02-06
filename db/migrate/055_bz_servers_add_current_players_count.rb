class BzServersAddCurrentPlayersCount < ActiveRecord::Migration
  def self.up
    add_column :bz_servers, :current_players_count, :integer, :default => 0
  end

  def self.down
    remove_column :bz_servers, :current_players_count
  end
end
