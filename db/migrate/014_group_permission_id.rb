class GroupPermissionId < ActiveRecord::Migration
  def self.up
    remove_column :groups, :access_level_id
    add_column :groups, :permission_id, :integer
  end

  def self.down
    add_column :groups, :access_level_id
    remove_column :groups, :permission_id, :integer
  end
end
