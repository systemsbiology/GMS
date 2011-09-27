class AddAncestryToAssayFiles < ActiveRecord::Migration
  def self.up
    add_column :assay_files, :ancestry, :string
    add_index :assay_files, :ancestry
  end

  def self.down
    remove_index :assay_files, :ancestry
    remove_column :assay_files, :ancestry
  end
end
