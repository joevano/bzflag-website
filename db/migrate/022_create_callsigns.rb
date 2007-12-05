class CreateCallsigns < ActiveRecord::Migration
  def self.up
    create_table :callsigns do |t|
      t.string :callsign

      t.timestamps
    end
  end

  def self.down
    drop_table :callsigns
  end
end
