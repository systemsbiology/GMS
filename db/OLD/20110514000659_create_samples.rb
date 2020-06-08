class CreateSamples < ActiveRecord::Migration[4.2]
  def self.up
    create_table :samples do |t|
      t.integer :id
      t.integer :isb_sample_id
      t.integer :sample_type_id
      t.string :status
      t.date :date_received
      t.string :protocol
      t.string :comments

      t.timestamps
    end
  end

  def self.down
    drop_table :samples
  end
end
