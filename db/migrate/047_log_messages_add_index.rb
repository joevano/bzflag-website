class LogMessagesAddIndex < ActiveRecord::Migration
  def self.up
    add_index :log_messages, [:bz_server_id, :log_type_id, :logged_at], :name => "index_log_messages"
  end

  def self.down
    remove_index :log_messages, :name => "index_log_messages"
  end
end
