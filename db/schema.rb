# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090629133544) do

  create_table "bz_servers", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "port"
    t.integer  "server_host_id"
    t.string   "map_name"
    t.integer  "last_chat_message_id"
    t.integer  "last_filtered_message_id"
    t.integer  "server_status_message_id"
    t.integer  "current_players_count",    :default => 0
    t.boolean  "is_test_server",           :default => false
    t.boolean  "is_disabled",              :default => false
  end

  create_table "callsigns", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
  end

  add_index "callsigns", ["name"], :name => "index_callsigns_on_name", :unique => true

  create_table "current_players", :force => true do |t|
    t.integer  "slot_index"
    t.boolean  "is_verified"
    t.boolean  "is_admin"
    t.string   "callsign"
    t.string   "email"
    t.integer  "bz_server_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "emails", :force => true do |t|
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "emails", ["email"], :name => "index_emails_on_email", :unique => true

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "groups_permissions", :id => false, :force => true do |t|
    t.integer "group_id"
    t.integer "permission_id"
  end

  create_table "groups_users", :id => false, :force => true do |t|
    t.integer "group_id"
    t.integer "user_id"
  end

  create_table "ips", :force => true do |t|
    t.string   "ip"
    t.string   "hostname"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "first_join_at"
    t.datetime "last_part_at"
  end

  add_index "ips", ["ip"], :name => "index_ips_on_ip", :unique => true

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
    t.integer  "player_connection_id"
  end

  add_index "log_messages", ["bz_server_id", "id", "log_type_id", "logged_at"], :name => "index_log_messages"
  add_index "log_messages", ["id"], :name => "index_log_messages_by_id"
  add_index "log_messages", ["log_type_id", "logged_at"], :name => "index_log_messages_log_type_logged_at"
  add_index "log_messages", ["player_connection_id", "log_type_id"], :name => "index_log_messages_on_player_connection_id_and_log_type_id"

  create_table "log_types", :force => true do |t|
    t.string   "token"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "log_types", ["token"], :name => "index_log_types_on_token", :unique => true

  create_table "messages", :force => true do |t|
    t.string   "text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "messages", ["text"], :name => "index_messages_on_text", :unique => true

  create_table "permissions", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
  end

  create_table "player_connections", :force => true do |t|
    t.integer  "bz_server_id"
    t.integer  "callsign_id"
    t.boolean  "is_verified"
    t.boolean  "is_admin"
    t.integer  "email_id"
    t.boolean  "website_access"
    t.integer  "bzid"
    t.integer  "ip_id"
    t.datetime "join_at"
    t.datetime "part_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "team_id"
    t.integer  "slot"
    t.boolean  "is_globaluser"
    t.boolean  "is_operator"
  end

  add_index "player_connections", ["bz_server_id", "callsign_id", "join_at"], :name => "index_player_connections_join_at"
  add_index "player_connections", ["bz_server_id", "part_at", "callsign_id"], :name => "index_player_connections"
  add_index "player_connections", ["callsign_id"], :name => "index_player_connections_on_callsign_id"
  add_index "player_connections", ["ip_id", "callsign_id", "is_verified", "is_admin", "is_globaluser", "is_operator", "join_at"], :name => "index_player_connections_search"

  create_table "server_hosts", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "hostname"
    t.string   "owner"
  end

  add_index "server_hosts", ["hostname"], :name => "index_server_hosts_on_hostname", :unique => true

  create_table "sessions", :force => true do |t|
    t.string   "session_id"
    t.text     "data"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "teams", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.integer  "bzid"
    t.string   "callsign"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ip"
  end

end
