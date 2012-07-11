# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110926182022) do

  create_table "acquisitions", :force => true do |t|
    t.integer "sample_id"
    t.integer "person_id"
    t.string  "method"
  end

  add_index "acquisitions", ["person_id", "sample_id"], :name => "person_id", :unique => true
  add_index "acquisitions", ["person_id"], :name => "acquisitions_person"
  add_index "acquisitions", ["sample_id"], :name => "acquisitions_sample"

  create_table "assays", :force => true do |t|
    t.string   "isb_assay_id"
    t.string   "media_id"
    t.string   "name"
    t.string   "vendor"
    t.string   "assay_type"
    t.string   "status"
    t.string   "technology"
    t.string   "description"
    t.date     "date_received"
    t.date     "date_transferred"
    t.date     "dated_backup"
    t.date     "qc_pass_date"
    t.boolean  "current"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "assemblies", :force => true do |t|
    t.integer  "genome_reference_id"
    t.integer  "assay_id"
    t.string   "name"
    t.string   "description"
    t.string   "location"
    t.string   "file_type"
    t.date     "file_date"
    t.string   "status",              :limit => 50
    t.text     "metadata"
    t.string   "disk_id",             :limit => 50
    t.string   "software"
    t.string   "software_version"
    t.date     "record_date"
    t.boolean  "current"
    t.text     "comments"
    t.integer  "created_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ancestry"
    t.datetime "coverage_data"
    t.datetime "statistics"
    t.datetime "bed_file"
  end

  create_table "assembly_files", :force => true do |t|
    t.integer  "genome_reference_id"
    t.integer  "assembly_id"
    t.integer  "file_type_id"
    t.string   "name"
    t.string   "description"
    t.string   "location"
    t.date     "file_date"
    t.text     "metadata"
    t.string   "disk_id",             :limit => 50
    t.string   "software"
    t.string   "software_version"
    t.date     "record_date"
    t.boolean  "current"
    t.text     "comments"
    t.integer  "created_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ancestry"
  end

  create_table "audits", :force => true do |t|
    t.integer  "auditable_id"
    t.string   "auditable_type"
    t.integer  "association_id"
    t.string   "association_type"
    t.integer  "user_id"
    t.string   "user_type"
    t.string   "username"
    t.string   "action"
    t.text     "audited_changes"
    t.integer  "version",          :default => 0
    t.string   "comment"
    t.string   "remote_address"
    t.datetime "created_at"
  end

  add_index "audits", ["association_id", "association_type"], :name => "association_index"
  add_index "audits", ["auditable_id", "auditable_type"], :name => "auditable_index"
  add_index "audits", ["created_at"], :name => "index_audits_on_created_at"
  add_index "audits", ["user_id", "user_type"], :name => "user_index"

  create_table "diagnoses", :force => true do |t|
    t.integer "person_id"
    t.integer "disease_id"
    t.string  "age_of_onset",        :limit => 50
    t.text    "disease_information"
    t.integer "output_order"
    t.date    "created_at"
    t.date    "updated_at"
  end

  add_index "diagnoses", ["person_id", "disease_id"], :name => "person_id", :unique => true

  create_table "diseases", :force => true do |t|
    t.string   "name"
    t.string   "omim_id"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "file_types", :force => true do |t|
    t.string   "type_name",  :limit => 50
    t.integer  "created_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "genome_references", :force => true do |t|
    t.string   "name"
    t.string   "build_name"
    t.string   "description"
    t.string   "code"
    t.string   "location"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "memberships", :force => true do |t|
    t.integer "pedigree_id"
    t.integer "person_id"
    t.string  "draw_duplicate"
  end

  add_index "memberships", ["pedigree_id", "person_id"], :name => "pedigree_id", :unique => true
  add_index "memberships", ["pedigree_id"], :name => "membership_pedigree"
  add_index "memberships", ["person_id"], :name => "membership_person"

  create_table "pedigrees", :force => true do |t|
    t.string   "isb_pedigree_id"
    t.string   "name"
    t.string   "tag"
    t.integer  "study_id"
    t.string   "directory"
    t.string   "description"
    t.string   "version"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "genotype_vector"
    t.datetime "quartet"
    t.datetime "autozygosity_hmm"
    t.datetime "relation_pairing"
  end

  add_index "pedigrees", ["isb_pedigree_id"], :name => "pedigrees_isb_pedigree_id"
  add_index "pedigrees", ["name", "tag"], :name => "index_pedigrees_on_name_and_tag", :unique => true

  create_table "people", :force => true do |t|
    t.string   "isb_person_id"
    t.string   "collaborator_id"
    t.string   "gender"
    t.date     "dob"
    t.date     "dod"
    t.boolean  "deceased",               :default => false, :null => false
    t.boolean  "planning_on_sequencing", :default => false
    t.boolean  "complete"
    t.boolean  "root"
    t.text     "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "people", ["isb_person_id"], :name => "index_people_on_isb_person_id", :unique => true

  create_table "person_aliases", :force => true do |t|
    t.integer  "person_id"
    t.string   "name"
    t.string   "value"
    t.string   "alias_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "person_aliases", ["person_id"], :name => "alias_person_id"

  create_table "phenotypes", :force => true do |t|
    t.integer  "disease_id"
    t.string   "name"
    t.string   "phenotype_type"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "relationships", :force => true do |t|
    t.string   "name",              :limit => 50
    t.integer  "person_id"
    t.integer  "relation_id"
    t.string   "relationship_type"
    t.integer  "relation_order"
    t.boolean  "divorced",                        :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "relationships", ["person_id", "relation_id", "relationship_type"], :name => "person_id", :unique => true

  create_table "report_types", :force => true do |t|
    t.string "name"
  end

  create_table "reports", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "report_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sample_assays", :force => true do |t|
    t.integer  "sample_id"
    t.integer  "assay_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sample_assays", ["assay_id"], :name => "sample_assays_assay"
  add_index "sample_assays", ["sample_id", "assay_id"], :name => "sample_id", :unique => true
  add_index "sample_assays", ["sample_id"], :name => "sample_assays_sample"

  create_table "sample_types", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.string   "tissue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "samples", :force => true do |t|
    t.string   "isb_sample_id"
    t.string   "customer_sample_id"
    t.integer  "sample_type_id"
    t.string   "sample_vendor_id"
    t.string   "status"
    t.date     "date_submitted"
    t.string   "protocol"
    t.string   "volume",             :limit => 25
    t.string   "concentration",      :limit => 25
    t.string   "quantity",           :limit => 25
    t.date     "date_received"
    t.text     "description"
    t.text     "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "samples", ["isb_sample_id"], :name => "samples_isb_sample_id"

  create_table "studies", :force => true do |t|
    t.string   "name"
    t.string   "tag",                       :limit => 50
    t.string   "lead"
    t.string   "collaborator"
    t.string   "collaborating_institution"
    t.string   "description"
    t.string   "contact"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "temp_objects", :force => true do |t|
    t.integer   "trans_id"
    t.string    "object_type"
    t.text      "object"
    t.timestamp "added",       :null => false
    t.datetime  "created_at"
    t.datetime  "updated_at"
  end

  create_table "traits", :force => true do |t|
    t.integer "person_id"
    t.integer "phenotype_id"
    t.string  "trait_information"
    t.string  "output_order"
  end

  add_index "traits", ["person_id", "phenotype_id"], :name => "person_id", :unique => true

end
