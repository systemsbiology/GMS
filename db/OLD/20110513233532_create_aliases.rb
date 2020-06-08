class CreateAliases < ActiveRecord::Migration[4.2]
  def self.up
    create_table :aliases do |t|
      t.integer :id
      t.string :name
      t.string :value
      t.string :type
      t.integer :person_id

      t.timestamps
    end
  end

  def self.down
    drop_table :aliases
  end
end
