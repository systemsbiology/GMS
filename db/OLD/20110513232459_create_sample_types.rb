class CreateSampleTypes < ActiveRecord::Migration[4.2]
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
