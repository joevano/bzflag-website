class AccessLevelTimestamps < ActiveRecord::Migration
  def self.up
    add_column :access_levels, :created_at, :datetime
    add_column :access_levels, :updated_at, :datetime
  end

  def self.down
    remove_column :access_levels, :created_at
    remove_column :access_levels, :updated_at
  end
end
