class CreateServerHosts < ActiveRecord::Migration
  def self.up
    create_table :server_hosts do |t|

      t.timestamps
      t.column :hostname, :string
      t.column :owner, :string
    end
  end

  def self.down
    drop_table :server_hosts
  end
end
