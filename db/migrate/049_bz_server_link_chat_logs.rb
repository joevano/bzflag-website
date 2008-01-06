class BzServerLinkChatLogs < ActiveRecord::Migration
  def self.up
    add_column :bz_servers, :last_chat_log_message_id, :integer
    add_column :bz_servers, :last_filtered_log_message_id, :integer
  end

  def self.down
    remove_column :bz_servers, :last_chat_log_message_id
    remove_column :bz_servers, :last_filtered_log_message_id
  end
end
