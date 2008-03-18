class BzServersAddDisabled < ActiveRecord::Migration
  def self.up
    add_column :bz_servers, :is_disabled, :boolean, :default => 0
  end

  def self.down
    remove_column :bz_servers, :is_disabled
  end
end
