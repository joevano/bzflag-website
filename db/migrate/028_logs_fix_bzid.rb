class LogsFixBzid < ActiveRecord::Migration
  def self.up
    remove_column :logs, :bzid_id
    add_column :logs, :bzid, :integer
  end

  def self.down
    remove_column :logs, :bzid
    add_column :logs, :bzid_id, :integer
  end
end
