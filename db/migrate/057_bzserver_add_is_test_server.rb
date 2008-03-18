class BzserverAddIsTestServer < ActiveRecord::Migration
  def self.up
    add_column :bz_servers, :is_test_server, :boolean, :default => 0
  end

  def self.down
    remove_column :bz_servers, :is_test_server
  end
end
