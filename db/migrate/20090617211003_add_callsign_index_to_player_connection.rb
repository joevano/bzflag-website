class AddCallsignIndexToPlayerConnection < ActiveRecord::Migration
  def self.up
    add_index :player_connections, :callsign_id
  end

  def self.down
    remove_index :player_connections, :callsign_id
  end
end
