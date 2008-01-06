class LogMessageAddIndex < ActiveRecord::Migration
  def self.up
    add_index "log_messages", "id", :name => "index_log_messages_by_id"
  end

  def self.down
    remove_index "log_messages", :name => "index_log_messages_by_id"
  end
end
