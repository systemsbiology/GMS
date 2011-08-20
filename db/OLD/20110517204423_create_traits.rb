class CreateTraits < ActiveRecord::Migration
  def self.up
    create_table :traits do |t|
      t.integer :id
      t.references :person
      t.references :phenotype
      t.string :value
      t.string :output_order
      t.timestamps
    end
  end

  def self.down
    drop_table :traits
  end
end
