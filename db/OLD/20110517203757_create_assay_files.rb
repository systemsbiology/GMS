class CreateAssayFiles < ActiveRecord::Migration
  def self.up
    create_table :assay_files do |t|
      t.integer :id
      t.integer :genome_reference_id
      t.string :name
      t.string :description
      t.string :location
      t.string :file_type
      t.text :metadata
      t.string :software
      t.string :software_version
      t.datetime :file_date
      t.boolean :current
      t.text :comments

      t.timestamps
    end
  end

  def self.down
    drop_table :assay_files
  end
end
