class GroupsTimestamps < ActiveRecord::Migration
  def self.up
    add_column :groups, :created_at, :datetime
    add_column :groups, :updated_at, :datetime
  end

  def self.down
    remove_column :groups, :created_at
    remove_column :groups, :updated_at
  end
end
