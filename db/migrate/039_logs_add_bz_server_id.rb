class LogsAddBzServerId < ActiveRecord::Migration
  def self.up
    add_column :logs, :bz_server_id, :integer
  end

  def self.down
    remove_column :logs, :bz_server_id
  end
end
