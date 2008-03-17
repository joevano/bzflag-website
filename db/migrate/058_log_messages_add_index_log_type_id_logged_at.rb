class LogMessagesAddIndexLogTypeIdLoggedAt < ActiveRecord::Migration
  def self.up
    add_index "log_messages", ["log_type_id", "logged_at"], :name => "index_log_messages_log_type_logged_at"
  end

  def self.down
    remove_index "log_messages", :name => "index_log_messages_log_type_logged_at"
  end
end
