class CreatePlayerConnections < ActiveRecord::Migration
  def self.up
    create_table :player_connections do |t|
      t.integer :bz_server_id
      t.integer :callsign_id
      t.boolean :is_verified
      t.boolean :is_admin
      t.integer :email_id
      t.boolean :website_access
      t.integer :bzid
      t.integer :ip_id
      t.datetime :join_at
      t.datetime :part_at

      t.timestamps
    end
  end

  def self.down
    drop_table :player_connections
  end
end
