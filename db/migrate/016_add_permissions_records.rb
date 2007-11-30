class AddPermissionsRecords < ActiveRecord::Migration
  def self.up
    Permission.destroy_all
    Permission.new(:name => 'Configuration Menu').save!
    Permission.new(:name => 'Admin Menu').save!
    Permission.new(:name => 'Ban').save!
    Permission.new(:name => 'Short Ban').save!
    Permission.new(:name => 'Map Upload').save!
    Permission.new(:name => 'Logs').save!
    Permission.new(:name => 'View Private Chat').save!
    Permission.new(:name => 'Player Info').save!
    Permission.new(:name => 'Server Control').save!
    Permission.new(:name => 'Test Server Control').save!
  end

  def self.down
    Permission.delete_all
  end
end
