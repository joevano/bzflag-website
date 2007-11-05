class CreateGroups < ActiveRecord::Migration
  def self.up
    create_table :groups do |t|
      t.column :name, :string
      t.column :access_level_id, :integer
    end
  end

  def self.down
    drop_table :groups
  end
end
