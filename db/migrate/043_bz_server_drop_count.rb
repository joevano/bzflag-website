class BzServerDropCount < ActiveRecord::Migration
  def self.up
    remove_column :bz_servers, :current_player_count
  end

  def self.down
    add_column :bz_servers, :current_player_count, :integer
  end
end
