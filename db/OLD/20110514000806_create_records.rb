class CreateRecords < ActiveRecord::Migration
  def self.up
    create_table :records do |t|
      t.integer :id
      t.integer :reference_id
      t.string :name
      t.string :location
      t.string :file_type
      t.text :metadata
      t.boolean :current
      t.datetime :created_at
      t.integer :created_by
      t.datetime :updated_at
      t.integer :updated_by

      t.timestamps
    end
  end

  def self.down
    drop_table :records
  end
end
