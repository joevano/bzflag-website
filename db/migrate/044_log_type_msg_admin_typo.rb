class LogTypeMsgAdminTypo < ActiveRecord::Migration
  def self.up
    lt = LogType.find_by_token("MSG-ADMINS")
    lt.token = "MSG-ADMIN"
    lt.save!
  end

  def self.down
    lt = LogType.find_by_token("MSG-ADMIN")
    lt.token = "MSG-ADMINS"
    lt.save!
  end
end
