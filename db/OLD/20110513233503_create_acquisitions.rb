class CreateAcquisitions < ActiveRecord::Migration[4.2]
  def self.up
    create_table :acquisitions do |t|
      t.integer :id
      t.integer :person_id
      t.integer :sample_id
      t.string :method

      t.timestamps
    end
  end

  def self.down
    drop_table :acquisitions
  end
end
