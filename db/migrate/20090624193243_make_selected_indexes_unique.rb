class MakeSelectedIndexesUnique < ActiveRecord::Migration
  def self.up
    remove_index :callsigns, :name
    remove_index :ips, :ip
    remove_index :messages, :text
    add_index :callsigns, :name, :unique => true
    add_index :emails, :email, :unique => true
    add_index :ips, :ip, :unique => true
    add_index :log_types, :token, :unique => true
    add_index :messages, :text, :unique => true
    add_index :server_hosts, :hostname, :unique => true
  end

  def self.down
    remove_index :callsigns, :name
    remove_index :emails, :email
    remove_index :ips, :ip
    remove_index :log_types, :token
    remove_index :messages, :text
    remove_index :server_hosts, :hostname
    add_index :callsigns, :name
    add_index :ips, :ip
    add_index :messages, :text
  end
end
