class PlayerConnectionAddIndex < ActiveRecord::Migration
  def self.up
    add_index :player_connections, [:bz_server_id, :part_at, :callsign_id], :name => "index_player_connections"
  end

  def self.down
    remove_index :player_connections, :name => "index_player_connections"
  end
end
