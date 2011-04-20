class CreatePoints < ActiveRecord::Migration
  def self.up
    create_table :points do |t|
      t.integer :option_id
      t.integer :position_id
      t.integer :user_id
      t.integer :session_id
      t.text :nutshell
      t.text :text
      t.boolean :is_pro

      t.timestamps
      
    end
  end

  def self.down
    drop_table :points
  end
end