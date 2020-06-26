class Setup < ActiveRecord::Migration[4.2]
  def self.up
    create_table :conditions do |t|
      t.string :name
      t.string :omim_id
      t.text :description
      t.timestamps
    end

    create_table :phenotypes do |t|
      t.references :condition
      t.string :name
      t.string :tag
      t.string :phenotype_type
      t.boolean :madeline_display
      t.text :description
      t.timestamps
    end

    create_table :people do |t|
      t.string :isb_person_id
      t.string :collaborator_id
      t.references :pedigree
      t.string :gender
      t.date :dob
      t.date :dod
      t.boolean :deceased, :default => false, :null => false
      t.boolean :planning_on_sequencing, :default => false, :null => false
      t.boolean :complete, :default => false, :null => false
      t.boolean :root, :default => false, :null => false
      t.text :comments
      t.timestamps
    end
    add_index :people, [:isb_person_id], :unique => true

    create_table :traits do |t|
      t.references :person
      t.references :phenotype
      t.string :value
      t.string :output_order
    end

    create_table :person_aliases do |t|
      t.references :person
      t.string :value
      t.string :alias_type
      t.timestamps
    end
    add_index :person_aliases, [:person_id], :name => "alias_person_id"

    create_table :pedigrees do |t|
      t.string :isb_pedigree_id
      t.string :name
      t.string :tag
      t.references :study
      t.string :directory
      t.string :description
      t.datetime :genotype_vector_date
      t.datetime :quartet_date
      t.datetime :autozygosity_date
      t.datetime :relation_pairing_date
      t.string :version
      t.timestamps
    end
    add_index :pedigrees, [:name, :tag], :unique => true
    add_index :pedigrees, [:isb_pedigree_id], :name => "pedigrees_isb_pedigree_id"

    create_table :memberships do |t|
      t.references :pedigree
      t.references :person
      t.string :draw_duplicate
    end

    create_table :file_types do |t|
      t.string :type_name
      t.integer :created_by
      t.timestamps
    end

    create_table :assembly_files do |t|
      t.references :genome_reference
      t.references :assembly
      t.references :file_types
      t.string :name
      t.string :description
      t.string :location
      t.string :ancestry
      t.date :file_date
      t.text :metadata
      t.string :disk_id
      t.string :software
      t.string :software_version
      t.date :record_date
      t.boolean :current
      t.text :comments
      t.integer :created_by
      t.timestamps
    end

    create_table :assemblies do |t|
      t.references :genome_reference
      t.references :assay
      t.string :name
      t.string :isb_assembly_id
      t.string :description
      t.string :location
      t.string :file_type
      t.date :file_date
      t.string :status
      t.text :metadata
      t.string :disk_id
      t.string :software
      t.string :software_version
      t.date :record_date
      t.boolean :current
      t.string :ancestry
      t.datetime :coveraged_data_date
      t.datetime :bed_file_date
      t.datetime :genotype_file_date
      t.text :comments
      t.integer :created_by
      t.timestamps
    end

    create_table :assays do |t|
      t.string :isb_assay_id
      t.string :media_id
      t.string :name
      t.string :vendor
      t.string :assay_type
      t.string :status
      t.string :technology
      t.string :description
      t.string :encypted_truecrypt_key
      t.date :date_received
      t.date :date_transferred
      t.date :dated_backup
      t.date :qc_pass_date
      t.boolean :current
      t.timestamps
    end

    create_table :sample_assays do |t|
      t.references :sample
      t.references :assay
      t.timestamps
    end

    create_table :relationships do |t|
      t.string :name
      t.references :person
      t.references :relation, foreign_key: {to_table: :people}
      t.string :relationship_type
      t.integer :relation_order
      t.boolean :divorced
      t.timestamps
    end

    create_table :genome_references do |t|
      t.string :name
      t.string :build_name
      t.string :description
      t.string :code
      t.string :location
      t.timestamps
    end

    create_table :sample_types do |t|
      t.string :name
      t.string :description
      t.string :tissue
      t.timestamps
    end

    create_table :samples do |t|
      t.string :isb_sample_id
      t.string :customer_sample_id
      t.references :sample_type
      t.references :pedigree
      t.string :sample_vendor_id
      t.string :status
      t.string :protocol
      t.string :volume
      t.string :concentration
      t.string :quantity
      t.date :date_submitted
      t.date :date_received
      t.text :description
      t.text :comments
      t.timestamps
    end

    add_index "samples", ["isb_sample_id"], :name => "samples_isb_sample_id"

    create_table :acquisitions do |t|
      t.references :sample
      t.references :person
      t.string :method
    end

    create_table :studies do |t|
      t.string :name
      t.string :tag
      t.string :lead
      t.string :collaborator
      t.string :collaborating_institute
      t.string :description
      t.string :contact
      t.timestamps
    end

    create_table :diagnoses do |t|
      t.references :person
      t.references :condition
      t.string :age_of_onset
      t.text :condition_information
      t.integer :output_order
      t.timestamps
    end

    create_table :diseases do |t|
      t.string :name
      t.string :omim_id
      t.text :description
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
    drop_table :file_types
    drop_table :assembly_files
    drop_table :assemblies
    drop_table :genome_references
    drop_table :relationships
    drop_table :assays
    drop_table :samples
    drop_table :sample_assays
    drop_table :acquisitions
    drop_table :sample_types
    drop_table :studies
    drop_table :diagnoses
    drop_table :diseases
  end
end
