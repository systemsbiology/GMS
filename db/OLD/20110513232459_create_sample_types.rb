class CreateSampleTypes < ActiveRecord::Migration
  def self.up
    create_table :sample_types do |t|
      t.integer :id
      t.string :name
      t.string :description
      t.string :tissue

      t.timestamps
    end
  end

  def self.down
    drop_table :sample_types
  end
end
