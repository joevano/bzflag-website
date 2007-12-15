class PlayerConnectionsAddSlot < ActiveRecord::Migration
  def self.up
    add_column :player_connections, :slot, :integer
  end

  def self.down
    remove_column :player_connections, :slot
  end
end
