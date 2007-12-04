class CreateLogTypes < ActiveRecord::Migration
  def self.up
    create_table :log_types do |t|
      t.string :token

      t.timestamps
    end

  end

  def self.down
    drop_table :log_types
  end
end
