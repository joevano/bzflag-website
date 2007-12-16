class MessagesAddIndex < ActiveRecord::Migration
  def self.up
    add_index :messages, :text
  end

  def self.down
    remove_index :messages, :text
  end
end
