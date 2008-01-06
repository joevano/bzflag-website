class BzServerAddServerStatus < ActiveRecord::Migration
  def self.up
    add_column :bz_servers, :server_status_log_message_id, :integer
  end

  def self.down
    remove_column :bz_servers, :server_status_log_message_id
  end
end
