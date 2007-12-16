class IpsAddIndex < ActiveRecord::Migration
  def self.up
    add_index :ips, :ip
  end

  def self.down
    remove_index :ips, :ip
  end
end
