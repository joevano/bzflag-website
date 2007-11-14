# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 15) do

  create_table "bz_servers", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "port"
    t.integer  "server_host_id"
    t.string   "map_name"
    t.datetime "last_chat_at"
    t.datetime "last_filtered_chat_at"
  end

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

  create_table "permissions", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
  end

  create_table "server_hosts", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "hostname"
    t.string   "owner"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id"
    t.text     "data"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "users", :force => true do |t|
    t.integer  "bzid"
    t.string   "callsign"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ip"
  end

end
