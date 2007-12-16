class LogTypesFixReport < ActiveRecord::Migration
  def self.up
    log = LogType.find_by_token("MSG-REPORT ")
    log.token = "MSG-REPORT"
    log.save!
  end

  def self.down
    log = LogType.find_by_token("MSG-REPORT")
    log.token = "MSG-REPORT "
    log.save!
  end
end
