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

ActiveRecord::Schema.define(:version => 20121211231345) do

  create_table "activities", :force => true do |t|
    t.boolean  "from_rda"
    t.string   "project_name"
    t.string   "initial_year"
    t.string   "duration"
    t.string   "total_grant_budget"
    t.string   "funding_sponsor"
    t.string   "funding_scheme"
    t.string   "project_type"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "published",          :default => false
    t.integer  "rda_grant_id"
  end

  create_table "activities_for_codes", :id => false, :force => true do |t|
    t.integer "activity_id"
    t.integer "for_code_id"
  end

  create_table "ands_handles", :force => true do |t|
    t.string   "key"
    t.integer  "assignable_id"
    t.string   "assignable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ands_parties", :force => true do |t|
    t.string   "given_name"
    t.string   "family_name"
    t.string   "title"
    t.string   "email"
    t.string   "key"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "group"
  end

  add_index "ands_parties", ["key"], :name => "index_ands_parties_on_key"

  create_table "ands_parties_memre_exports", :id => false, :force => true do |t|
    t.integer "ands_party_id"
    t.integer "memre_export_id"
  end

  create_table "ands_publishables", :force => true do |t|
    t.string   "collection_name"
    t.text     "collection_description"
    t.string   "research_group"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id"
    t.string   "access_rights"
    t.integer  "ands_rights_id"
    t.integer  "moderator_id"
    t.string   "status",                 :default => "U"
    t.text     "address"
    t.boolean  "has_temporal_coverage",  :default => false
    t.date     "coverage_start_date"
    t.date     "coverage_end_date"
    t.boolean  "published",              :default => true
  end

  create_table "ands_publishables_ands_subjects", :id => false, :force => true do |t|
    t.integer "ands_publishable_id"
    t.integer "ands_subject_id"
  end

  create_table "ands_publishables_for_codes", :id => false, :force => true do |t|
    t.integer "ands_publishable_id"
    t.integer "for_code_id"
  end

  create_table "ands_publishables_seo_codes", :id => false, :force => true do |t|
    t.integer "ands_publishable_id"
    t.integer "seo_code_id"
  end

  create_table "ands_related_infos", :force => true do |t|
    t.string   "info_type"
    t.string   "identifier"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "detailable_id"
    t.string   "detailable_type"
  end

  create_table "ands_related_objects", :force => true do |t|
    t.string   "handle"
    t.string   "description"
    t.string   "relation_type"
    t.integer  "ands_publishable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "relation"
    t.string   "name"
  end

  create_table "ands_rights", :force => true do |t|
    t.string   "license_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ands_subjects", :force => true do |t|
    t.string   "keyword"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "attachments", :force => true do |t|
    t.string   "filename",                :limit => 2048
    t.string   "format"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "dataset_id"
    t.text     "description"
    t.string   "preview_file",            :limit => 2048
    t.string   "preview_mime_type"
    t.integer  "instrument_file_type_id"
    t.boolean  "indelible",                               :default => false
  end

  create_table "datasets", :force => true do |t|
    t.integer  "sample_id"
    t.integer  "instrument_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "external_data_source"
    t.integer  "external_id"
  end

  create_table "eln_blogs", :force => true do |t|
    t.string   "name"
    t.integer  "user_id",    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "eln_export_metadata", :force => true do |t|
    t.integer  "eln_export_id"
    t.string   "key"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "eln_exports", :force => true do |t|
    t.integer  "dataset_id"
    t.string   "title"
    t.string   "section"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.string   "blog_name"
    t.string   "post_url"
  end

  create_table "experiments", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id"
    t.string   "url",                   :limit => 2048
    t.string   "document_file_name",    :limit => 2048
    t.string   "document_content_type"
    t.integer  "document_file_size"
    t.datetime "document_updated_at"
  end

  create_table "fluorescent_labels", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "settings_id"
  end

  create_table "for_codes", :force => true do |t|
    t.string   "code"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "instrument_file_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "filter"
    t.string   "parser_name"
    t.string   "visualisation_handler"
  end

  create_table "instrument_file_types_instruments", :id => false, :force => true do |t|
    t.integer "instrument_file_type_id"
    t.integer "instrument_id"
  end

  create_table "instrument_rules", :force => true do |t|
    t.integer  "instrument_id"
    t.text     "unique_list"
    t.text     "exclusive_list"
    t.text     "indelible_list"
    t.text     "metadata_list"
    t.text     "visualisation_list"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "instruments", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "instrument_class"
    t.boolean  "is_available"
    t.string   "upload_prompt"
    t.text     "description"
    t.string   "email"
    t.string   "voice"
    t.text     "address"
    t.string   "managed_by"
    t.boolean  "published",        :default => false
  end

  create_table "membrane_properties", :force => true do |t|
    t.string   "name"
    t.string   "property_type"
    t.text     "description"
    t.string   "property_units"
    t.string   "qualifier1"
    t.string   "qualifier2"
    t.string   "qualifier3"
    t.text     "measurement_techniques"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "memre_exports", :force => true do |t|
    t.integer  "dataset_id"
    t.string   "material_name"
    t.string   "material_class_name"
    t.string   "creator"
    t.string   "form_description"
    t.string   "name"
    t.string   "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "metadata_values", :force => true do |t|
    t.string   "key"
    t.string   "value"
    t.integer  "dataset_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "core"
    t.integer  "attachment_id"
    t.boolean  "supplied"
  end

  create_table "project_experiments", :id => false, :force => true do |t|
    t.integer "project_id",    :null => false
    t.integer "experiment_id", :null => false
  end

  create_table "project_members", :id => false, :force => true do |t|
    t.integer "project_id"
    t.integer "user_id"
    t.boolean "collaborating", :default => false
  end

  add_index "project_members", ["project_id"], :name => "project_members_project_id_index"

  create_table "projects", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "url",                   :limit => 2048
    t.string   "document_file_name",    :limit => 2048
    t.string   "document_content_type"
    t.integer  "document_file_size"
    t.datetime "document_updated_at"
    t.boolean  "slide_request_sent",                    :default => false
  end

  create_table "property_details", :force => true do |t|
    t.integer  "memre_export_id"
    t.string   "name"
    t.string   "measurement_technique"
    t.string   "type_of_property"
    t.string   "property_units"
    t.string   "description"
    t.string   "qualifier_1"
    t.string   "qualifier_2"
    t.string   "qualifier_3"
    t.string   "info_type"
    t.string   "identifier"
    t.string   "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rda_grants", :force => true do |t|
    t.string   "group"
    t.string   "key"
    t.string   "primary_name"
    t.string   "alternative_name"
    t.text     "description"
    t.string   "grant_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "samples", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "samplable_id"
    t.string   "samplable_type"
    t.string   "external_data_source"
    t.integer  "external_id"
  end

  create_table "seo_codes", :force => true do |t|
    t.string   "code"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "settings", :force => true do |t|
    t.string  "start_handle_range"
    t.string  "end_handle_range"
    t.string  "slide_scanning_email"
    t.integer "file_size_limit",      :default => 64
  end

  create_table "slide_guidelines", :force => true do |t|
    t.text     "description"
    t.integer  "settings_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                 :default => "",    :null => false
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.integer  "failed_attempts",       :default => 0
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "status"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "login",                 :default => "",    :null => false
    t.string   "phone_number"
    t.string   "authentication_token"
    t.boolean  "eln_enabled"
    t.string   "nmr_username"
    t.string   "supervisor_name"
    t.string   "supervisor_email"
    t.boolean  "is_student",            :default => false
    t.boolean  "memre_enabled"
    t.boolean  "nmr_enabled"
    t.boolean  "slide_request_enabled"
  end

  add_index "users", ["authentication_token"], :name => "index_users_on_authentication_token", :unique => true
  add_index "users", ["login"], :name => "index_users_on_login", :unique => true

end
