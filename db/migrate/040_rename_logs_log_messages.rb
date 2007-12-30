class RenameLogsLogMessages < ActiveRecord::Migration
  def self.up
    create_table "log_messages", :force => true do |t|
      t.integer  "log_type_id"
      t.integer  "callsign_id"
      t.integer  "to_callsign_id"
      t.datetime "logged_at"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "bzid"
      t.integer  "team_id"
      t.integer  "message_id"
      t.integer  "bz_server_id"
    end
  end

  def self.down
    drop_table :log_messages
  end
end
