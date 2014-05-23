class Setup < ActiveRecord::Migration
  def self.up
    create_table :conditions do |t|
      t.integer :id
      t.string :name
      t.string :omim_id
      t.text :description
      t.timestamps
    end

    create_table :phenotypes do |t|
      t.integer :id
      t.references :condition
      t.string :name
      t.text :description
      t.timestamps
    end

    create_table :people do |t|
      t.integer :id
      t.string :isb_person_id
      t.string :collaborator_id
      t.string :gender
      t.date :dob
      t.date :dod
      t.boolean :deceased, :default => false, :null => false
      t.text :comments
      t.timestamps
    end
    add_index :people, [:isb_person_id], :unique => true

    create_table :traits do |t|
      t.integer :id
      t.references :person
      t.references :phenotype
      t.string :value
      t.string :output_order
    end

    create_table :person_aliases do |t|
      t.integer :id
      t.references :person
      t.string :name
      t.string :value
      t.string :alias_type
      t.timestamps
    end 
    add_index :person_aliases, [:person_id], :name => "alias_person_id"

    create_table :pedigrees do |t|
      t.integer :id
      t.string :isb_pedigree_id
      t.string :name
      t.string :tag
      t.references :study
      t.string :directory
      t.string :description
      t.string :version
      t.timestamps
    end
    add_index :pedigrees, [:name, :tag], :unique => true
    add_index :pedigrees, [:isb_pedigree_id], :name => "pedigrees_isb_pedigree_id"

    create_table :memberships do |t|
      t.integer :id
      t.references :pedigree
      t.references :person
      t.string :draw_duplicate
    end

    create_table :assembly_files do |t|
      t.integer :id
      t.references :genome_reference
      t.references :assay
      t.string :name
      t.string :description
      t.string :location
      t.string :file_type
      t.date :file_date
      t.text :metadata
      t.string :software
      t.string :software_version
      t.date :record_date
      t.boolean :current
      t.text :comments
      t.integer :created_by
      t.timestamps
    end

    create table :assemblies do |t|
      t.integer :id
      t.references :genome_reference
      t.references :assay
      t.string :name
      t.string :description
      t.string :location
      t.string :file_type
      t.date :file_date
      t.text :metadata
      t.string :software
      t.string :software_version
      t.date :record_date
      t.boolean :current
      t.text :comments
      t.integer :created_by
      t.timestamps
    end

    create_table :assays do |t|
      t.integer :id
      t.string :name
      t.string :assay_type
      t.string :technology
      t.string :description
      t.date :date
      t.timestamps
    end

    create_table :sample_assays do |t|
      t.integer :id
      t.references :sample
      t.references :assay
      t.timestamps
    end

    create_table :relationships do |t|
      t.integer :id
      t.string :name
      t.references :person
      t.integer :parent
      t.integer :child
      t.string :relationship_type
      t.timestamps
    end

    create_table :genome_references do |t|
      t.integer :id
      t.string :name
      t.string :description
      t.string :code
      t.string :location
      t.timestamps
    end

    create_table :sample_types do |t|
      t.integer :id
      t.string :name
      t.string :description
      t.string :tissue
      t.timestamps
    end

    create_table :samples do |t|
      t.integer :id
      t.string :isb_sample_id
      t.references :sample_type
      t.string :sample_vendor_id
      t.string :status
      t.string :protocol
      t.date :date_received
      t.text :description
      t.text :comments
      t.timestamps
    end

    add_index "samples", ["isb_sample_id"], :name => "samples_isb_sample_id"

    create_table :acquisitions do |t|
      t.integer :id
      t.references :sample
      t.references :person
      t.string :method
    end

    create_table :studies do |t|
      t.integer :id
      t.string :name
      t.string :principal
      t.string :collaborator
      t.string :collaborating_institute
      t.string :description
      t.string :contact
      t.timestamps
    end
  end

  def self.down
    drop_table :conditions
    drop_table :pedigrees
    drop_table :memberships
    drop_table :people
    drop_table :person_aliases
    drop_table :phenotypes
    drop_table :traits
    drop_table :assembly_files
    drop_table :assemblies
    drop_table :genome_references
    drop_table :relationships
    drop_table :samples
    drop_table :sample_assays
    drop_table :acquisitions
    drop_table :sample_types
    drop_table :studies
  end
end
