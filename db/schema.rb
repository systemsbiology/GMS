# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_06_08_030506) do

  create_table "acquisitions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "sample_id"
    t.integer "person_id"
    t.string "method"
  end

  create_table "assays", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "isb_assay_id"
    t.string "media_id"
    t.string "name"
    t.string "vendor"
    t.string "assay_type"
    t.string "status"
    t.string "technology"
    t.string "description"
    t.string "encypted_truecrypt_key"
    t.date "date_received"
    t.date "date_transferred"
    t.date "dated_backup"
    t.date "qc_pass_date"
    t.boolean "current"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "assemblies", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "genome_reference_id"
    t.integer "assay_id"
    t.string "name"
    t.string "isb_assembly_id"
    t.string "description"
    t.string "location"
    t.string "file_type"
    t.date "file_date"
    t.string "status"
    t.text "metadata"
    t.string "disk_id"
    t.string "software"
    t.string "software_version"
    t.date "record_date"
    t.boolean "current"
    t.string "ancestry"
    t.datetime "coveraged_data_date"
    t.datetime "bed_file_date"
    t.datetime "genotype_file_date"
    t.text "comments"
    t.integer "created_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "assembly_files", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "genome_reference_id"
    t.integer "assembly_id"
    t.integer "file_types_id"
    t.string "name"
    t.string "description"
    t.string "location"
    t.string "ancestry"
    t.date "file_date"
    t.text "metadata"
    t.string "disk_id"
    t.string "software"
    t.string "software_version"
    t.date "record_date"
    t.boolean "current"
    t.text "comments"
    t.integer "created_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "audits", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "auditable_id"
    t.string "auditable_type"
    t.integer "association_id"
    t.string "association_type"
    t.integer "user_id"
    t.string "user_type"
    t.string "username"
    t.string "action"
    t.text "audited_changes"
    t.integer "version", default: 0
    t.string "comment"
    t.string "remote_address"
    t.datetime "created_at"
    t.index ["association_id", "association_type"], name: "association_index"
    t.index ["auditable_id", "auditable_type"], name: "auditable_index"
    t.index ["created_at"], name: "index_audits_on_created_at"
    t.index ["user_id", "user_type"], name: "user_index"
  end

  create_table "conditions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.string "omim_id"
    t.text "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "diagnoses", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "person_id"
    t.integer "condition_id"
    t.string "age_of_onset"
    t.text "condition_information"
    t.integer "output_order"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "diseases", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.string "omim_id"
    t.text "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "file_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "type_name"
    t.integer "created_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "genome_references", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.string "build_name"
    t.string "description"
    t.string "code"
    t.string "location"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "memberships", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "pedigree_id"
    t.integer "person_id"
    t.string "draw_duplicate"
  end

  create_table "pedigrees", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "isb_pedigree_id"
    t.string "name"
    t.string "tag"
    t.integer "study_id"
    t.string "directory"
    t.string "description"
    t.datetime "genotype_vector_date"
    t.datetime "quartet_date"
    t.datetime "autozygosity_date"
    t.datetime "relation_pairing_date"
    t.string "version"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["isb_pedigree_id"], name: "pedigrees_isb_pedigree_id"
    t.index ["name", "tag"], name: "index_pedigrees_on_name_and_tag", unique: true
  end

  create_table "people", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "isb_person_id"
    t.string "collaborator_id"
    t.integer "pedigree_id"
    t.string "gender"
    t.date "dob"
    t.date "dod"
    t.boolean "deceased", default: false, null: false
    t.boolean "planning_on_sequencing", default: false, null: false
    t.boolean "complete", default: false, null: false
    t.boolean "root", default: false, null: false
    t.text "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["isb_person_id"], name: "index_people_on_isb_person_id", unique: true
  end

  create_table "person_aliases", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "person_id"
    t.string "value"
    t.string "alias_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["person_id"], name: "alias_person_id"
  end

  create_table "phenotypes", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "condition_id"
    t.string "name"
    t.string "tag"
    t.string "phenotype_type"
    t.boolean "madeline_display"
    t.text "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "relationships", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.integer "person_id"
    t.integer "relation_id"
    t.string "relationship_type"
    t.integer "relation_order"
    t.boolean "divorced"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["relation_id"], name: "fk_rails_a4ec8001b4"
  end

  create_table "reports", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.string "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sample_assays", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "sample_id"
    t.integer "assay_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sample_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.string "tissue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "samples", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "isb_sample_id"
    t.string "customer_sample_id"
    t.integer "sample_type_id"
    t.integer "pedigree_id"
    t.string "sample_vendor_id"
    t.string "status"
    t.string "protocol"
    t.string "volume"
    t.string "concentration"
    t.string "quantity"
    t.date "date_submitted"
    t.date "date_received"
    t.text "description"
    t.text "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["isb_sample_id"], name: "samples_isb_sample_id"
  end

  create_table "sessions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "session_id", null: false
    t.text "data"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "studies", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.string "tag"
    t.string "lead"
    t.string "collaborator"
    t.string "collaborating_institute"
    t.string "description"
    t.string "contact"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "traits", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "person_id"
    t.integer "phenotype_id"
    t.string "value"
    t.string "output_order"
  end

  add_foreign_key "relationships", "people", column: "relation_id"
end
