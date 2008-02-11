class AddLogTypeServerMapname < ActiveRecord::Migration
  def self.up
    LogType.new(:token => 'SERVER-MAPNAME').save!
  end

  def self.down
    LogType.find_by_token('SERVER-MAPNAME').destroy
  end
end
