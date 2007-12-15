class LogsAddTeam < ActiveRecord::Migration
  def self.up
    add_column :logs, :team_id, :integer
  end

  def self.down
    remove_column :logs, :team_id
  end
end
