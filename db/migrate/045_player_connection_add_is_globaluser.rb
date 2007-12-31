class PlayerConnectionAddIsGlobaluser < ActiveRecord::Migration
  def self.up
    add_column :player_connections, :is_globaluser, :boolean
  end

  def self.down
    remove_column :player_connections, :is_globaluser
  end
end
