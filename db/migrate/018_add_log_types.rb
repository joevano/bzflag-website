class AddLogTypes < ActiveRecord::Migration
  def self.up
    down
    LogType.new(:token => 'PLAYER-JOIN').save!
    LogType.new(:token => 'PLAYER-PART').save!
    LogType.new(:token => 'PLAYER-AUTH').save!
    LogType.new(:token => 'SERVER-STATUS').save!
    LogType.new(:token => 'MSG-BROADCAST').save!
    LogType.new(:token => 'MSG-FILTERED').save!
    LogType.new(:token => 'MSG-DIRECT').save!
    LogType.new(:token => 'MSG-TEAM').save!
    LogType.new(:token => 'MSG-REPORT ').save!
    LogType.new(:token => 'MSG-COMMAND').save!
    LogType.new(:token => 'MSG-ADMINS').save!
    LogType.new(:token => 'PLAYERS').save!
  end

  def self.down
    LogType.delete_all
  end
end
