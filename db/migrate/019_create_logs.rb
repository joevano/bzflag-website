class CreateLogs < ActiveRecord::Migration
  def self.up
    create_table :logs do |t|
      t.integer :log_type_id
      t.integer :callsign_id
      t.integer :to_callsign_id
      t.string :message
      t.integer :bzid_id
      t.datetime :logged_at

      t.timestamps
    end
  end

  def self.down
    drop_table :logs
  end
end
