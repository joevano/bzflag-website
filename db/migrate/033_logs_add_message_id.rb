class LogsAddMessageId < ActiveRecord::Migration
  def self.up
    remove_column :logs, :message
    add_column :logs, :message_id, :integer
  end

  def self.down
    add_column :logs, :message, :string
    remove_column :logs, :message_id
  end
end
