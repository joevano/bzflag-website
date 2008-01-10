class PlayerConnectionsAddSearchIndex < ActiveRecord::Migration
  def self.up
    add_index :player_connections, [:ip_id, :callsign_id, :is_verified, :is_admin, :is_globaluser, :is_operator, :join_at], :name => "index_player_connections_search"
  end

  def self.down
    remove_index :player_connections, :name => "index_player_connections_search"
  end
end
