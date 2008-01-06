class LogMessage < ActiveRecord::Base
  belongs_to :log_type
  belongs_to :callsign
  belongs_to :to_callsign, :class_name => "Callsign", :foreign_key => "to_callsign_id"
  belongs_to :team
  belongs_to :message
  belongs_to :bz_server
  belongs_to :server_last_chat, :class_name => "BzServer", :foreign_key => "last_chat_message_id"
  belongs_to :server_last_filtered_chat, :class_name => "BzServer", :foreign_key => "last_filtered_chat_message_id"
end
