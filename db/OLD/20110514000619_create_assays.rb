class CreateAssays < ActiveRecord::Migration
  def self.up
    create_table :assays do |t|
      t.integer :id
      t.integer :sample_id
      t.integer :record_id
      t.string :name
      t.string :type
      t.string :technology
      t.string :description

      t.timestamps
    end
  end

  def self.down
    drop_table :assays
  end
end
