class CreateBzServers < ActiveRecord::Migration
  def self.up
    create_table :bz_servers do |t|

      t.timestamps
      t.column :port, :integer
      t.column :server_host_id, :integer
      t.column :map_name, :string
      t.column :last_chat_at, :datetime
      t.column :last_filtered_chat_at, :datetime
    end
  end

  def self.down
    drop_table :bz_servers
  end
end
