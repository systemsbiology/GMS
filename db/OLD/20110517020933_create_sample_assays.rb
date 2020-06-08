class CreateSampleAssays < ActiveRecord::Migration[4.2]
  def self.up
    create_table :sample_assays do |t|
      t.integer :id
      t.integer :sample_id
      t.integer :assay_id

      t.timestamps
    end
  end

  def self.down
    drop_table :sample_assays
  end
end
