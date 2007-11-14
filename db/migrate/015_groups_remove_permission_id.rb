class GroupsRemovePermissionId < ActiveRecord::Migration
  def self.up
    remove_column :groups, :permission_id
  end

  def self.down
    add_column :groups, :permission_id, :integer
  end
end
