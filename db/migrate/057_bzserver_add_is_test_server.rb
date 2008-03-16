class BzserverAddIsTestServer < ActiveRecord::Migration
  def self.up
    add_column :bz_servers, :is_test_server, :boolean, :default => nil
  end

  def self.down
    remove_column :bz_servers, :is_test_server
  end
end
