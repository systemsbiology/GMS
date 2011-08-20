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

ActiveRecord::Schema.define(:version => 20110819233419) do

  create_table "acquisitions", :force => true do |t|
    t.integer "sample_id"
    t.integer "person_id"
    t.string  "method"
  end

  create_table "aliases", :force => true do |t|
    t.integer  "person_id"
    t.string   "name"
    t.string   "value"
    t.string   "alias_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "aliases", ["person_id"], :name => "alias_person_id"

  create_table "assay_files", :force => true do |t|
    t.integer  "genome_reference_id"
    t.integer  "assay_id"
    t.string   "name"
    t.string   "description"
    t.string   "location"
    t.string   "file_type"
    t.text     "metadata"
    t.string   "software"
    t.string   "software_version"
    t.date     "record_date"
    t.boolean  "current"
    t.text     "comments"
    t.integer  "created_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "assays", :force => true do |t|
    t.string   "name"
    t.string   "assay_type"
    t.string   "technology"
    t.string   "description"
    t.date     "date"
    t.datetime "created_at"
    t.datetime "updated_at"
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

  create_table "diseases", :force => true do |t|
    t.string   "name"
    t.string   "omim_id"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "genome_references", :force => true do |t|
    t.string   "name"
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

  create_table "pedigrees", :force => true do |t|
    t.string   "isb_pedigree_id"
    t.string   "name"
    t.string   "tag"
    t.integer  "study_id"
    t.string   "description"
    t.string   "version"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pedigrees", ["isb_pedigree_id"], :name => "pedigrees_isb_pedigree_id"
  add_index "pedigrees", ["name", "tag"], :name => "index_pedigrees_on_name_and_tag", :unique => true

  create_table "people", :force => true do |t|
    t.string   "isb_person_id"
    t.string   "collaborator_id"
    t.string   "gender"
    t.date     "dob"
    t.date     "dod"
    t.boolean  "deceased",        :default => false, :null => false
    t.text     "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "people", ["isb_person_id"], :name => "index_people_on_isb_person_id", :unique => true

  create_table "phenotypes", :force => true do |t|
    t.integer  "disease_id"
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "relationships", :force => true do |t|
    t.string   "name"
    t.integer  "person_id"
    t.integer  "parent"
    t.integer  "child"
    t.string   "relationship_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sample_assays", :force => true do |t|
    t.integer  "sample_id"
    t.integer  "assay_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sample_types", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.string   "tissue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "samples", :force => true do |t|
    t.string   "isb_sample_id"
    t.integer  "sample_type_id"
    t.string   "vendor"
    t.string   "status"
    t.string   "protocol"
    t.date     "date_received"
    t.text     "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "samples", ["isb_sample_id"], :name => "samples_isb_sample_id"

  create_table "studies", :force => true do |t|
    t.string   "name"
    t.string   "principle"
    t.string   "collaborator"
    t.string   "description"
    t.string   "contact"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "traits", :force => true do |t|
    t.integer "person_id"
    t.integer "phenotype_id"
    t.string  "value"
    t.string  "output_order"
  end

end
