class BzServerDropLogTimes < ActiveRecord::Migration
  def self.up
    remove_column :bz_servers, :last_chat_at
    remove_column :bz_servers, :last_filtered_chat_at
  end

  def self.down
    add_column :bz_servers, :last_chat_at, :datetime
    add_column :bz_servers, :last_filtered_chat_at, :datetime
  end
end
