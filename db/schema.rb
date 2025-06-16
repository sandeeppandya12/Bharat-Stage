# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2025_05_15_060350) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "about_us", force: :cascade do |t|
    t.text "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "account_categories", force: :cascade do |t|
    t.integer "account_id"
    t.integer "category_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "account_groups_account_groups", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "account_groups_group_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["account_groups_group_id"], name: "index_account_groups_account_groups_on_account_groups_group_id"
    t.index ["account_id"], name: "index_account_groups_account_groups_on_account_id"
  end

  create_table "account_groups_groups", force: :cascade do |t|
    t.string "name"
    t.jsonb "settings"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "meeting_id"
  end

  create_table "accounts", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "full_phone_number"
    t.integer "country_code"
    t.bigint "phone_number"
    t.string "email"
    t.boolean "activated", default: false, null: false
    t.string "device_id"
    t.text "unique_auth_id"
    t.string "password_digest"
    t.string "type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "user_name"
    t.string "platform"
    t.string "user_type"
    t.integer "app_language_id"
    t.datetime "last_visit_at"
    t.boolean "is_blacklisted", default: false
    t.date "suspend_until"
    t.integer "status", default: 0, null: false
    t.string "full_name"
    t.integer "role_id"
    t.string "gender"
    t.date "date_of_birth"
    t.integer "age"
    t.boolean "terms_accepted", default: false, null: false
    t.string "roles", default: "artist"
    t.boolean "is_mobile_verified", default: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "reset_token_expires_at"
    t.text "description"
    t.string "languages", default: [], array: true
    t.string "portfolio_links", default: [], array: true
    t.string "height"
    t.integer "weight"
    t.string "location"
    t.string "user_role"
    t.string "experience_level"
    t.boolean "blocked", default: false
    t.string "locations"
    t.string "verification_token"
    t.jsonb "social_media_links", default: {}
    t.boolean "is_email_verify", default: false, null: false
    t.string "comet_chat_auth_token"
    t.string "comet_chat_uid"
    t.string "razorpay_customer_id"
    t.index ["is_blacklisted"], name: "index_accounts_on_is_blacklisted"
  end

  create_table "accounts_categories", id: false, force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "category_id", null: false
    t.index ["account_id"], name: "index_accounts_categories_on_account_id"
    t.index ["category_id"], name: "index_accounts_categories_on_category_id"
  end

  create_table "accounts_chats", force: :cascade do |t|
    t.bigint "account_id"
    t.bigint "chat_id"
    t.string "status"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "muted", default: false
    t.index ["account_id"], name: "index_accounts_chats_on_account_id"
    t.index ["chat_id"], name: "index_accounts_chats_on_chat_id"
  end

  create_table "accounts_sub_categories", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "sub_category_id", null: false
    t.integer "experience_level", default: 0
    t.index ["account_id"], name: "index_accounts_sub_categories_on_account_id"
    t.index ["sub_category_id"], name: "index_accounts_sub_categories_on_sub_category_id"
  end

  create_table "achievements", force: :cascade do |t|
    t.string "title"
    t.date "achievement_date"
    t.text "detail"
    t.string "url"
    t.integer "profile_bio_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "action_mailbox_inbound_emails", force: :cascade do |t|
    t.integer "status", default: 0, null: false
    t.string "message_id", null: false
    t.string "message_checksum", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["message_id", "message_checksum"], name: "index_action_mailbox_inbound_emails_uniqueness", unique: true
  end

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.boolean "default_image", default: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.string "service_name"
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "activities", force: :cascade do |t|
    t.string "trackable_type"
    t.bigint "trackable_id"
    t.string "owner_type"
    t.bigint "owner_id"
    t.string "key"
    t.text "parameters"
    t.string "recipient_type"
    t.bigint "recipient_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_id", "owner_type"], name: "index_activities_on_owner_id_and_owner_type"
    t.index ["owner_type", "owner_id"], name: "index_activities_on_owner_type_and_owner_id"
    t.index ["recipient_id", "recipient_type"], name: "index_activities_on_recipient_id_and_recipient_type"
    t.index ["recipient_type", "recipient_id"], name: "index_activities_on_recipient_type_and_recipient_id"
    t.index ["trackable_id", "trackable_type"], name: "index_activities_on_trackable_id_and_trackable_type"
    t.index ["trackable_type", "trackable_id"], name: "index_activities_on_trackable_type_and_trackable_id"
  end

  create_table "addressables", force: :cascade do |t|
    t.bigint "shipment_id", null: false
    t.text "address"
    t.text "address2"
    t.string "city"
    t.string "country"
    t.string "email"
    t.string "name"
    t.string "phone"
    t.text "instructions"
    t.string "type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["shipment_id"], name: "index_addressables_on_shipment_id"
  end

  create_table "addresses", force: :cascade do |t|
    t.string "country"
    t.float "latitude"
    t.float "longitude"
    t.string "address"
    t.integer "addressble_id"
    t.string "addressble_type"
    t.integer "address_type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.integer "sign_in_count"
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "advertisements", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.integer "plan_id"
    t.string "duration"
    t.integer "advertisement_for"
    t.integer "status"
    t.integer "seller_account_id"
    t.datetime "start_at"
    t.datetime "expire_at"
  end

  create_table "arrival_windows", force: :cascade do |t|
    t.datetime "begin_at"
    t.datetime "end_at"
    t.boolean "exclude_begin", default: true
    t.boolean "exclude_end", default: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "addressable_id"
  end

  create_table "attachments", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "colour"
    t.string "layout"
    t.string "page_size"
    t.string "scale"
    t.string "print_sides"
    t.integer "print_pages_from"
    t.integer "print_pages_to"
    t.integer "total_pages"
    t.boolean "is_expired", default: false
    t.integer "total_attachment_pages"
    t.string "pdf_url"
    t.boolean "is_printed", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "files"
    t.integer "status"
    t.index ["account_id"], name: "index_attachments_on_account_id"
  end

  create_table "availabilities", force: :cascade do |t|
    t.bigint "service_provider_id"
    t.string "start_time"
    t.string "end_time"
    t.string "unavailable_start_time"
    t.string "unavailable_end_time"
    t.string "availability_date"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.jsonb "timeslots"
    t.integer "available_slots_count"
    t.index ["service_provider_id"], name: "index_availabilities_on_service_provider_id"
  end

  create_table "black_list_users", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["account_id"], name: "index_black_list_users_on_account_id"
  end

  create_table "block_users", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "current_user_id"
    t.bigint "account_id"
    t.index ["account_id"], name: "index_block_users_on_account_id"
    t.index ["current_user_id"], name: "index_block_users_on_current_user_id"
  end

  create_table "brands", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "currency", default: 0
  end

  create_table "bx_block_appointment_management_booked_slots", force: :cascade do |t|
    t.bigint "order_id"
    t.string "start_time"
    t.string "end_time"
    t.bigint "service_provider_id"
    t.date "booking_date"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "bx_block_attachment_file_attachments", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "colour"
    t.string "layout"
    t.string "page_size"
    t.string "scale"
    t.string "print_sides"
    t.integer "print_pages_from"
    t.integer "print_pages_to"
    t.integer "total_pages"
    t.boolean "is_expired", default: false
    t.integer "total_attachment_pages"
    t.string "pdf_url"
    t.boolean "is_printed", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["account_id"], name: "index_bx_block_attachment_file_attachments_on_account_id"
  end

  create_table "bx_block_baselinereporting_baseline_reportings", force: :cascade do |t|
    t.string "sos_time"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "bx_block_chatbackuprestore_chat_messages", force: :cascade do |t|
    t.integer "account_id"
    t.integer "chat_room_id"
    t.string "message"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "bx_block_chatbackuprestore_chat_rooms", force: :cascade do |t|
    t.integer "account_id"
    t.integer "chat_user"
    t.boolean "is_permitted", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "bx_block_content_management_content_managments", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.boolean "status"
    t.float "price"
    t.integer "user_type"
    t.string "quantity"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "publish_date"
  end

  create_table "bx_block_custom_forms_custom_forms", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.bigint "phone_number"
    t.string "email"
    t.string "organization"
    t.string "team_name"
    t.integer "i_am"
    t.integer "gender"
    t.string "address"
    t.string "city"
    t.string "state"
    t.string "country"
    t.integer "zip_code"
    t.integer "account_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "stars_rating"
  end

  create_table "bx_block_custom_user_subs_subscriptions", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.decimal "price"
    t.date "valid_up_to"
    t.string "razorpay_plan_id"
    t.boolean "is_plan_used", default: false
  end

  create_table "bx_block_dashboard_candidates", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "address"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "bx_block_documentstorage_folders", force: :cascade do |t|
    t.integer "gallery_id"
    t.string "folder_name"
    t.integer "folder_type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "bx_block_documentstorage_galleries", force: :cascade do |t|
    t.integer "gallery_type"
    t.integer "account_id"
  end

  create_table "bx_block_emergency_emergencies", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.integer "type", null: false
    t.string "phone_number", null: false
    t.string "created_by", null: false
    t.string "updated_by"
    t.boolean "is_active", default: true, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "bx_block_productdescription_productdescriptions", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.datetime "manufacture_date"
    t.integer "availability"
    t.integer "stock_qty"
    t.float "price"
    t.boolean "recommended"
    t.boolean "on_sale"
    t.decimal "sale_price"
    t.integer "product_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "bx_block_profile_artist_profiles", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.text "description"
    t.string "languages", default: [], array: true
    t.string "portfolio_links", default: [], array: true
    t.string "social_media_links", array: true
    t.string "height"
    t.integer "weight"
    t.string "location"
    t.string "gender"
    t.string "role"
    t.string "experience_level"
    t.bigint "account_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "age"
    t.index ["account_id"], name: "index_bx_block_profile_artist_profiles_on_account_id"
  end

  create_table "bx_block_profile_associated_projects", force: :cascade do |t|
    t.integer "project_id"
    t.integer "associated_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "bx_block_profile_associateds", force: :cascade do |t|
    t.string "associated_with_name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "bx_block_profile_awards", force: :cascade do |t|
    t.string "title"
    t.string "associated_with"
    t.string "issuer"
    t.datetime "issue_date"
    t.text "description"
    t.boolean "make_public", default: false, null: false
    t.integer "profile_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "bx_block_profile_career_experience_employment_types", force: :cascade do |t|
    t.integer "career_experience_id"
    t.integer "employment_type_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "bx_block_profile_career_experience_industry", force: :cascade do |t|
    t.integer "career_experience_id"
    t.integer "industry_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "bx_block_profile_career_experience_system_experiences", force: :cascade do |t|
    t.integer "career_experience_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "system_experience_id"
  end

  create_table "bx_block_profile_career_experiences", force: :cascade do |t|
    t.string "job_title"
    t.date "start_date"
    t.date "end_date"
    t.string "company_name"
    t.text "description"
    t.string "add_key_achievements", default: [], array: true
    t.boolean "make_key_achievements_public", default: false, null: false
    t.integer "profile_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.decimal "current_salary", default: "0.0"
    t.text "notice_period"
    t.date "notice_period_end_date"
    t.boolean "currently_working_here", default: false
  end

  create_table "bx_block_profile_courses", force: :cascade do |t|
    t.string "course_name"
    t.string "duration"
    t.string "year"
    t.integer "profile_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "bx_block_profile_current_annual_salaries", force: :cascade do |t|
    t.string "current_annual_salary"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "bx_block_profile_current_annual_salary_current_status", force: :cascade do |t|
    t.integer "current_status_id"
    t.integer "current_annual_salary_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "bx_block_profile_current_status", force: :cascade do |t|
    t.string "most_recent_job_title"
    t.string "company_name"
    t.text "notice_period"
    t.date "end_date"
    t.integer "profile_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "bx_block_profile_current_status_employment_types", force: :cascade do |t|
    t.integer "current_status_id"
    t.integer "employment_type_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "bx_block_profile_current_status_industries", force: :cascade do |t|
    t.integer "current_status_id"
    t.integer "industry_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "bx_block_profile_custom_user_profile_fields", force: :cascade do |t|
    t.string "name"
    t.string "field_type"
    t.boolean "is_enable", default: true, null: false
    t.boolean "is_required", default: true, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_bx_block_profile_custom_user_profile_fields_on_name"
  end

  create_table "bx_block_profile_degree_educational_qualifications", force: :cascade do |t|
    t.integer "educational_qualification_id"
    t.integer "degree_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "bx_block_profile_degrees", force: :cascade do |t|
    t.string "degree_name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "bx_block_profile_educational_qualification_field_study", force: :cascade do |t|
    t.integer "educational_qualification_id"
    t.integer "field_study_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "bx_block_profile_educational_qualifications", force: :cascade do |t|
    t.string "school_name"
    t.date "start_date"
    t.date "end_date"
    t.string "grades"
    t.text "description"
    t.boolean "make_grades_public", default: false, null: false
    t.integer "profile_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "bx_block_profile_employment_types", force: :cascade do |t|
    t.string "employment_type_name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "bx_block_profile_field_study", force: :cascade do |t|
    t.string "field_of_study"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "bx_block_profile_hobbies_and_interests", force: :cascade do |t|
    t.string "title"
    t.string "category"
    t.text "description"
    t.boolean "make_public", default: false, null: false
    t.integer "profile_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "bx_block_profile_industries", force: :cascade do |t|
    t.string "industry_name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "bx_block_profile_languages", force: :cascade do |t|
    t.string "language"
    t.string "proficiency"
    t.integer "profile_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "bx_block_profile_projects", force: :cascade do |t|
    t.string "project_name"
    t.date "start_date"
    t.date "end_date"
    t.string "add_members"
    t.string "url"
    t.text "description"
    t.boolean "make_projects_public", default: false, null: false
    t.integer "profile_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "bx_block_profile_publication_patents", force: :cascade do |t|
    t.string "title"
    t.string "publication"
    t.string "authors"
    t.string "url"
    t.text "description"
    t.boolean "make_public", default: false, null: false
    t.integer "profile_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "bx_block_profile_system_experiences", force: :cascade do |t|
    t.string "system_experience"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "bx_block_profile_test_score_and_courses", force: :cascade do |t|
    t.string "title"
    t.string "associated_with"
    t.string "score"
    t.datetime "test_date"
    t.text "description"
    t.boolean "make_public", default: false, null: false
    t.integer "profile_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "bx_block_razorpay_razorpay_orders", force: :cascade do |t|
    t.float "amount"
    t.string "status"
    t.string "razorpay_order_id"
    t.string "receipt"
    t.bigint "account_id"
    t.bigint "order_id"
    t.string "entity"
    t.decimal "amount_paid"
    t.decimal "amount_due"
    t.string "currency"
    t.string "offer_id"
    t.bigint "attempts"
    t.json "notes"
    t.index ["account_id"], name: "index_bx_block_razorpay_razorpay_orders_on_account_id"
    t.index ["order_id"], name: "index_bx_block_razorpay_razorpay_orders_on_order_id"
    t.index ["razorpay_order_id"], name: "index_bx_block_razorpay_razorpay_orders_on_razorpay_order_id"
    t.index ["status"], name: "index_bx_block_razorpay_razorpay_orders_on_status"
  end

  create_table "bx_block_razorpay_verify_payment_signatures", force: :cascade do |t|
    t.bigint "razorpay_order_id"
    t.string "rpay_order_id"
    t.string "razorpay_payment_id"
    t.string "razorpay_signature"
    t.boolean "status", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["razorpay_order_id"], name: "razorpay_order_id_to_vps"
    t.index ["razorpay_payment_id"], name: "razorpay_payment_id_to_vps"
    t.index ["rpay_order_id"], name: "rpay_order_id_to_vps"
  end

  create_table "bx_block_stripe_integration_customers", force: :cascade do |t|
    t.string "stripe_id"
    t.bigint "account_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["account_id"], name: "index_bx_block_stripe_integration_customers_on_account_id"
  end

  create_table "bx_block_stripe_integration_webhook_events", force: :cascade do |t|
    t.string "event_id"
    t.string "event_type"
    t.string "object_id"
    t.string "payable_reference"
    t.text "payload"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["event_id"], name: "index_bx_block_stripe_integration_webhook_events_on_event_id"
    t.index ["event_type"], name: "index_bx_block_stripe_integration_webhook_events_on_event_type"
    t.index ["object_id"], name: "index_bx_block_stripe_integration_webhook_events_on_object_id"
    t.index ["payable_reference"], name: "index_bx_stripe_events_on_payable_ref"
  end

  create_table "bx_block_terms_and_conditions_terms_and_conditions", force: :cascade do |t|
    t.integer "account_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "description"
    t.string "title"
  end

  create_table "bx_block_terms_and_conditions_user_term_and_conditions", force: :cascade do |t|
    t.integer "account_id"
    t.integer "terms_and_condition_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "is_accepted"
  end

  create_table "careers", force: :cascade do |t|
    t.string "profession"
    t.boolean "is_current", default: false
    t.string "experience_from"
    t.string "experience_to"
    t.string "payscale"
    t.string "company_name"
    t.string "accomplishment", array: true
    t.integer "sector"
    t.integer "profile_bio_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "catalogue_reviews", force: :cascade do |t|
    t.bigint "catalogue_id", null: false
    t.string "comment"
    t.integer "rating"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["catalogue_id"], name: "index_catalogue_reviews_on_catalogue_id"
  end

  create_table "catalogue_tags", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "catalogue_variant_colors", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "catalogue_variant_sizes", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "catalogue_variants", force: :cascade do |t|
    t.bigint "catalogue_id", null: false
    t.bigint "catalogue_variant_color_id"
    t.bigint "catalogue_variant_size_id"
    t.decimal "price"
    t.integer "stock_qty"
    t.boolean "on_sale"
    t.decimal "sale_price"
    t.decimal "discount_price"
    t.float "length"
    t.float "breadth"
    t.float "height"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "block_qty"
    t.index ["catalogue_id"], name: "index_catalogue_variants_on_catalogue_id"
    t.index ["catalogue_variant_color_id"], name: "index_catalogue_variants_on_catalogue_variant_color_id"
    t.index ["catalogue_variant_size_id"], name: "index_catalogue_variants_on_catalogue_variant_size_id"
  end

  create_table "catalogues", force: :cascade do |t|
    t.bigint "category_id", null: false
    t.bigint "sub_category_id", null: false
    t.bigint "brand_id"
    t.string "name"
    t.string "sku"
    t.string "description"
    t.datetime "manufacture_date"
    t.float "length"
    t.float "breadth"
    t.float "height"
    t.integer "availability"
    t.integer "stock_qty"
    t.decimal "weight"
    t.float "price"
    t.boolean "recommended"
    t.boolean "on_sale"
    t.decimal "sale_price"
    t.decimal "discount"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "block_qty"
    t.index ["brand_id"], name: "index_catalogues_on_brand_id"
    t.index ["category_id"], name: "index_catalogues_on_category_id"
    t.index ["sub_category_id"], name: "index_catalogues_on_sub_category_id"
  end

  create_table "catalogues_tags", force: :cascade do |t|
    t.bigint "catalogue_id", null: false
    t.bigint "catalogue_tag_id", null: false
    t.index ["catalogue_id"], name: "index_catalogues_tags_on_catalogue_id"
    t.index ["catalogue_tag_id"], name: "index_catalogues_tags_on_catalogue_tag_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "admin_user_id"
    t.integer "rank"
    t.string "light_icon"
    t.string "light_icon_active"
    t.string "light_icon_inactive"
    t.string "dark_icon"
    t.string "dark_icon_active"
    t.string "dark_icon_inactive"
    t.integer "identifier"
  end

  create_table "categories_sub_categories", force: :cascade do |t|
    t.bigint "category_id", null: false
    t.bigint "sub_category_id", null: false
    t.index ["category_id"], name: "index_categories_sub_categories_on_category_id"
    t.index ["sub_category_id"], name: "index_categories_sub_categories_on_sub_category_id"
  end

  create_table "chat_messages", force: :cascade do |t|
    t.bigint "account_id"
    t.bigint "chat_id"
    t.string "message", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "is_mark_read", default: false
    t.integer "message_type"
    t.integer "read_by", default: [], array: true
    t.index ["account_id"], name: "index_chat_messages_on_account_id"
    t.index ["chat_id"], name: "index_chat_messages_on_chat_id"
  end

  create_table "chats", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "name", default: "", null: false
    t.integer "chat_type", null: false
  end

  create_table "cod_values", force: :cascade do |t|
    t.bigint "shipment_id", null: false
    t.float "amount"
    t.string "currency", default: "RS"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["shipment_id"], name: "index_cod_values_on_shipment_id"
  end

  create_table "comments", force: :cascade do |t|
    t.bigint "account_id"
    t.bigint "commentable_id"
    t.string "commentable_type"
    t.text "comment"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["account_id"], name: "index_comments_on_account_id"
  end

  create_table "contacts", force: :cascade do |t|
    t.bigint "account_id"
    t.string "email"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "first_name"
    t.string "last_name"
    t.string "full_phone_number"
    t.string "subject"
    t.text "message"
    t.index ["account_id"], name: "index_contacts_on_account_id"
  end

  create_table "coordinates", force: :cascade do |t|
    t.string "latitude"
    t.string "longitude"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "addressable_id"
  end

  create_table "coupon_codes", force: :cascade do |t|
    t.string "title"
    t.string "description"
    t.string "code"
    t.string "discount_type", default: "flat"
    t.decimal "discount"
    t.datetime "valid_from"
    t.datetime "valid_to"
    t.decimal "min_cart_value"
    t.decimal "max_cart_value"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "create_shipments", force: :cascade do |t|
    t.boolean "auto_assign_drivers", default: false
    t.string "requested_by"
    t.string "shipper_id"
    t.string "waybill"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "cta", force: :cascade do |t|
    t.string "headline"
    t.text "description"
    t.bigint "category_id"
    t.string "long_background_image"
    t.string "square_background_image"
    t.string "button_text"
    t.string "redirect_url"
    t.integer "text_alignment"
    t.integer "button_alignment"
    t.boolean "is_square_cta"
    t.boolean "is_long_rectangle_cta"
    t.boolean "is_text_cta"
    t.boolean "is_image_cta"
    t.boolean "has_button"
    t.boolean "visible_on_home_page"
    t.boolean "visible_on_details_page"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["category_id"], name: "index_cta_on_category_id"
  end

  create_table "deliveries", force: :cascade do |t|
    t.bigint "shipment_id", null: false
    t.text "address"
    t.text "address2"
    t.string "city"
    t.string "country"
    t.string "email"
    t.string "name"
    t.string "phone"
    t.text "instructions"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["shipment_id"], name: "index_deliveries_on_shipment_id"
  end

  create_table "delivery_address_orders", force: :cascade do |t|
    t.bigint "order_management_order_id", null: false
    t.bigint "delivery_address_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["delivery_address_id"], name: "index_delivery_address_orders_on_delivery_address_id"
    t.index ["order_management_order_id"], name: "index_delivery_address_orders_on_order_management_order_id"
  end

  create_table "delivery_addresses", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "address"
    t.string "name"
    t.string "flat_no"
    t.string "zip_code"
    t.string "phone_number"
    t.datetime "deleted_at"
    t.float "latitude"
    t.float "longitude"
    t.boolean "residential", default: true
    t.string "city"
    t.string "state_code"
    t.string "country_code"
    t.string "state"
    t.string "country"
    t.string "address_line_2"
    t.string "address_type", default: "home"
    t.string "address_for", default: "shipping"
    t.boolean "is_default", default: false
    t.string "landmark"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["account_id"], name: "index_delivery_addresses_on_account_id"
  end

  create_table "dimensions", force: :cascade do |t|
    t.bigint "item_id", null: false
    t.float "height"
    t.float "length"
    t.float "width"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["item_id"], name: "index_dimensions_on_item_id"
  end

  create_table "educations", force: :cascade do |t|
    t.string "qualification"
    t.integer "profile_bio_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "year_from"
    t.string "year_to"
    t.text "description"
  end

  create_table "email_notifications", force: :cascade do |t|
    t.bigint "notification_id", null: false
    t.string "send_to_email"
    t.datetime "sent_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["notification_id"], name: "index_email_notifications_on_notification_id"
  end

  create_table "email_otps", force: :cascade do |t|
    t.string "email"
    t.integer "pin"
    t.boolean "activated", default: false, null: false
    t.datetime "valid_until"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "favourites", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "favouriteable_id"
    t.string "favouriteable_type"
    t.integer "user_id"
  end

  create_table "global_settings", force: :cascade do |t|
    t.string "notice_period"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "items", force: :cascade do |t|
    t.bigint "shipment_id", null: false
    t.string "ref_id"
    t.float "weight"
    t.integer "quantity"
    t.boolean "stackable", default: true
    t.integer "item_type", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["shipment_id"], name: "index_items_on_shipment_id"
  end

  create_table "landing_pages", force: :cascade do |t|
    t.string "title"
    t.string "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "likes", force: :cascade do |t|
    t.integer "like_by_id"
    t.string "likeable_type", null: false
    t.bigint "likeable_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["likeable_type", "likeable_id"], name: "index_likes_on_likeable_type_and_likeable_id"
  end

  create_table "locations", force: :cascade do |t|
    t.float "latitude"
    t.float "longitude"
    t.integer "van_id"
    t.text "address"
    t.string "locationable_type"
    t.bigint "locationable_id"
    t.index ["locationable_type", "locationable_id"], name: "index_locations_on_locationable_type_and_locationable_id"
  end

  create_table "media", force: :cascade do |t|
    t.string "imageable_type"
    t.string "imageable_id"
    t.string "file_name"
    t.string "file_size"
    t.string "presigned_url"
    t.integer "status"
    t.string "category"
  end

  create_table "notifications", force: :cascade do |t|
    t.integer "created_by"
    t.string "headings"
    t.string "contents"
    t.string "app_url"
    t.boolean "is_read", default: false
    t.datetime "read_at"
    t.bigint "account_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "title"
    t.boolean "chat_notification", default: false
    t.index ["account_id"], name: "index_notifications_on_account_id"
  end

  create_table "order_items", force: :cascade do |t|
    t.bigint "order_management_order_id", null: false
    t.integer "quantity"
    t.decimal "unit_price"
    t.decimal "total_price"
    t.decimal "old_unit_price"
    t.string "status"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "catalogue_id", null: false
    t.bigint "catalogue_variant_id", null: false
    t.integer "order_status_id"
    t.datetime "placed_at"
    t.datetime "confirmed_at"
    t.datetime "in_transit_at"
    t.datetime "delivered_at"
    t.datetime "cancelled_at"
    t.datetime "refunded_at"
    t.boolean "manage_placed_status", default: false
    t.boolean "manage_cancelled_status", default: false
    t.index ["catalogue_id"], name: "index_order_items_on_catalogue_id"
    t.index ["catalogue_variant_id"], name: "index_order_items_on_catalogue_variant_id"
    t.index ["order_management_order_id"], name: "index_order_items_on_order_management_order_id"
  end

  create_table "order_management_orders", force: :cascade do |t|
    t.string "order_number"
    t.integer "amount"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "account_id"
    t.bigint "coupon_code_id"
    t.bigint "delivery_address_id"
    t.decimal "sub_total", default: "0.0"
    t.decimal "total", default: "0.0"
    t.string "status"
    t.decimal "applied_discount", default: "0.0"
    t.text "cancellation_reason"
    t.datetime "order_date"
    t.boolean "is_gift", default: false
    t.datetime "placed_at"
    t.datetime "confirmed_at"
    t.datetime "in_transit_at"
    t.datetime "delivered_at"
    t.datetime "cancelled_at"
    t.datetime "refunded_at"
    t.string "source"
    t.string "shipment_id"
    t.string "delivery_charges"
    t.string "tracking_url"
    t.datetime "schedule_time"
    t.datetime "payment_failed_at"
    t.datetime "returned_at"
    t.decimal "tax_charges", default: "0.0"
    t.integer "deliver_by"
    t.string "tracking_number"
    t.boolean "is_error", default: false
    t.string "delivery_error_message"
    t.datetime "payment_pending_at"
    t.integer "order_status_id"
    t.boolean "is_group", default: true
    t.boolean "is_availability_checked", default: false
    t.decimal "shipping_charge"
    t.decimal "shipping_discount"
    t.decimal "shipping_net_amt"
    t.decimal "shipping_total"
    t.float "total_tax"
    t.string "razorpay_order_id"
    t.boolean "charged"
    t.boolean "invoiced"
    t.string "invoice_id"
    t.string "custom_label"
    t.index ["account_id"], name: "index_order_management_orders_on_account_id"
    t.index ["coupon_code_id"], name: "index_order_management_orders_on_coupon_code_id"
  end

  create_table "order_statuses", force: :cascade do |t|
    t.string "name"
    t.string "status"
    t.boolean "active", default: true
    t.string "event_name"
    t.string "message"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "order_trackings", force: :cascade do |t|
    t.string "parent_type"
    t.bigint "parent_id"
    t.integer "tracking_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["parent_type", "parent_id"], name: "index_order_trackings_on_parent_type_and_parent_id"
  end

  create_table "order_transactions", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "order_management_order_id", null: false
    t.string "charge_id"
    t.integer "amount"
    t.string "currency"
    t.string "charge_status"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["account_id"], name: "index_order_transactions_on_account_id"
    t.index ["order_management_order_id"], name: "index_order_transactions_on_order_management_order_id"
  end

  create_table "pickups", force: :cascade do |t|
    t.bigint "shipment_id", null: false
    t.text "address"
    t.text "address2"
    t.string "city"
    t.string "country"
    t.string "email"
    t.string "name"
    t.string "phone"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["shipment_id"], name: "index_pickups_on_shipment_id"
  end

  create_table "posts", force: :cascade do |t|
    t.string "name", null: false
    t.string "description"
    t.bigint "category_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "body"
    t.string "location"
    t.integer "account_id"
    t.bigint "sub_category_id"
    t.index ["category_id"], name: "index_posts_on_category_id"
  end

  create_table "preferences", force: :cascade do |t|
    t.integer "seeking"
    t.string "discover_people", array: true
    t.text "location"
    t.integer "distance"
    t.integer "height_type"
    t.integer "body_type"
    t.integer "religion"
    t.integer "smoking"
    t.integer "drinking"
    t.integer "profile_bio_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "friend", default: false
    t.boolean "business", default: false
    t.boolean "match_making", default: false
    t.boolean "travel_partner", default: false
    t.boolean "cross_path", default: false
    t.integer "age_range_start"
    t.integer "age_range_end"
    t.string "height_range_start"
    t.string "height_range_end"
    t.integer "account_id"
  end

  create_table "print_prices", force: :cascade do |t|
    t.string "page_size"
    t.string "colors"
    t.float "single_side"
    t.float "double_side"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "privacy_policies", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "profile_bios", force: :cascade do |t|
    t.integer "account_id"
    t.string "height"
    t.string "weight"
    t.integer "height_type"
    t.integer "weight_type"
    t.integer "body_type"
    t.integer "mother_tougue"
    t.integer "religion"
    t.integer "zodiac"
    t.integer "marital_status"
    t.string "languages", array: true
    t.text "about_me"
    t.string "personality", array: true
    t.string "interests", array: true
    t.integer "smoking"
    t.integer "drinking"
    t.integer "looking_for"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "about_business"
    t.jsonb "custom_attributes"
  end

  create_table "profiles", force: :cascade do |t|
    t.string "country"
    t.string "address"
    t.string "postal_code"
    t.integer "account_id"
    t.string "photo"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "city"
  end

  create_table "push_notifications", force: :cascade do |t|
    t.bigint "account_id"
    t.string "push_notificable_type", null: false
    t.bigint "push_notificable_id", null: false
    t.string "remarks"
    t.boolean "is_read", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "notify_type"
    t.index ["account_id"], name: "index_push_notifications_on_account_id"
    t.index ["push_notificable_type", "push_notificable_id"], name: "index_push_notification_type_and_id"
  end

  create_table "recurring_subscriptions", force: :cascade do |t|
    t.string "name"
    t.string "fee"
    t.date "billing_date"
    t.integer "billing_frequency"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "account_id"
    t.index ["account_id"], name: "index_recurring_subscriptions_on_account_id"
  end

  create_table "requests", force: :cascade do |t|
    t.integer "sender_id"
    t.integer "status", default: 0
    t.integer "account_group_id"
    t.string "request_text"
    t.string "rejection_reason"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "account_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "seller_accounts", force: :cascade do |t|
    t.string "firm_name"
    t.string "full_phone_number"
    t.text "location"
    t.integer "country_code"
    t.bigint "phone_number"
    t.string "gstin_number"
    t.boolean "wholesaler"
    t.boolean "retailer"
    t.boolean "manufacturer"
    t.boolean "hallmarking_center"
    t.float "buy_gold"
    t.float "buy_silver"
    t.float "sell_gold"
    t.float "sell_silver"
    t.string "deal_in", default: [], array: true
    t.text "about_us"
    t.boolean "activated", default: false, null: false
    t.bigint "account_id", null: false
    t.decimal "lat", precision: 10, scale: 6
    t.decimal "long", precision: 10, scale: 6
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["account_id"], name: "index_seller_accounts_on_account_id"
  end

  create_table "settings", force: :cascade do |t|
    t.string "title"
    t.string "name"
    t.bigint "account_id"
    t.boolean "two_factor_enabled", default: false, null: false
    t.boolean "email_notification", default: true, null: false
    t.boolean "in_app_notification", default: true, null: false
    t.boolean "desktop_notification", default: true, null: false
    t.boolean "chat_notification", default: true
    t.index ["account_id"], name: "index_settings_on_account_id"
  end

  create_table "shipment_values", force: :cascade do |t|
    t.bigint "shipment_id", null: false
    t.float "amount"
    t.string "currency"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["shipment_id"], name: "index_shipment_values_on_shipment_id"
  end

  create_table "shipments", force: :cascade do |t|
    t.bigint "create_shipment_id", null: false
    t.string "ref_id"
    t.boolean "full_truck", default: false
    t.text "load_description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["create_shipment_id"], name: "index_shipments_on_create_shipment_id"
  end

  create_table "shopping_cart_order_items", force: :cascade do |t|
    t.integer "order_id"
    t.integer "catalogue_id"
    t.float "price"
    t.integer "quantity", default: 0
    t.boolean "taxable", default: false
    t.float "taxable_value", default: 0.0
    t.float "other_charges"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "shopping_cart_orders", force: :cascade do |t|
    t.bigint "customer_id"
    t.integer "address_id"
    t.integer "status"
    t.float "total_fees"
    t.integer "total_items"
    t.float "total_tax"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["customer_id"], name: "index_shopping_cart_orders_on_customer_id"
  end

  create_table "sms_otps", force: :cascade do |t|
    t.string "full_phone_number"
    t.integer "pin"
    t.boolean "activated", default: false, null: false
    t.datetime "valid_until"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "sub_categories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "parent_id"
    t.integer "rank"
    t.bigint "category_id"
    t.integer "experience_levels"
    t.index ["category_id"], name: "index_sub_categories_on_category_id"
  end

  create_table "sub_scription_orders", force: :cascade do |t|
    t.integer "account_id"
    t.integer "subscription_id"
    t.integer "gst", default: 0
    t.integer "sub_total", default: 0
    t.integer "total", default: 0
    t.datetime "order_date"
    t.datetime "valid_date"
    t.string "status"
    t.string "order_number"
    t.boolean "auto_renewal", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "active_plan", default: false
  end

  create_table "subscribes", force: :cascade do |t|
    t.string "email"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "taggings", force: :cascade do |t|
    t.bigint "tag_id"
    t.string "taggable_type"
    t.bigint "taggable_id"
    t.string "tagger_type"
    t.bigint "tagger_id"
    t.string "context", limit: 128
    t.datetime "created_at"
    t.string "tenant", limit: 128
    t.index ["context"], name: "index_taggings_on_context"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type", "context"], name: "taggings_taggable_context_idx"
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id"
    t.index ["taggable_type", "taggable_id"], name: "index_taggings_on_taggable_type_and_taggable_id"
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
    t.index ["tagger_type", "tagger_id"], name: "index_taggings_on_tagger_type_and_tagger_id"
    t.index ["tenant"], name: "index_taggings_on_tenant"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "testimonials", force: :cascade do |t|
    t.string "name"
    t.string "designation"
    t.text "content"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "trackings", force: :cascade do |t|
    t.string "status"
    t.string "tracking_number"
    t.datetime "date"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "user_careers", force: :cascade do |t|
    t.string "project_name"
    t.string "role"
    t.string "start_date"
    t.string "end_date"
    t.boolean "is_ongoing", default: false
    t.string "location"
    t.string "project_link", array: true
    t.text "description"
    t.bigint "account_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "start_year"
    t.integer "end_year"
    t.index ["account_id"], name: "index_user_careers_on_account_id"
  end

  create_table "user_categories", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "category_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["account_id"], name: "index_user_categories_on_account_id"
    t.index ["category_id"], name: "index_user_categories_on_category_id"
  end

  create_table "user_course_exams", force: :cascade do |t|
    t.integer "course_id"
    t.integer "quiz_and_mock_exam_id"
    t.integer "flash_card_id"
    t.integer "theme_id"
    t.integer "account_id"
    t.integer "lesson_id"
    t.integer "point", default: 0
    t.string "exam_type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "status", default: "not started"
    t.integer "quiz_and_answer_polling_id"
  end

  create_table "user_educations", force: :cascade do |t|
    t.string "institute_name"
    t.string "qualification"
    t.string "start_date"
    t.string "end_date"
    t.boolean "is_ongoing"
    t.string "location"
    t.bigint "account_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "start_year"
    t.integer "end_year"
    t.index ["account_id"], name: "index_user_educations_on_account_id"
  end

  create_table "user_languages", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "user_links", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "key"
    t.string "value"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["account_id"], name: "index_user_links_on_account_id"
  end

  create_table "user_skill_sub_categories", force: :cascade do |t|
    t.bigint "user_skill_id", null: false
    t.string "sub_category"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_skill_id"], name: "index_user_skill_sub_categories_on_user_skill_id"
  end

  create_table "user_skills", force: :cascade do |t|
    t.string "experience_level"
    t.bigint "account_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["account_id"], name: "index_user_skills_on_account_id"
  end

  create_table "user_sub_categories", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "sub_category_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["account_id"], name: "index_user_sub_categories_on_account_id"
    t.index ["sub_category_id"], name: "index_user_sub_categories_on_sub_category_id"
  end

  create_table "user_subscriptions", force: :cascade do |t|
    t.integer "account_id"
    t.integer "subscription_id"
  end

  create_table "van_members", force: :cascade do |t|
    t.integer "account_id"
    t.integer "van_id"
  end

  create_table "vans", force: :cascade do |t|
    t.string "name"
    t.text "bio"
    t.boolean "is_offline"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "view_profiles", force: :cascade do |t|
    t.integer "profile_bio_id"
    t.integer "view_by_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "account_id"
  end

  add_foreign_key "account_groups_account_groups", "account_groups_groups"
  add_foreign_key "account_groups_account_groups", "accounts"
  add_foreign_key "accounts_sub_categories", "accounts"
  add_foreign_key "accounts_sub_categories", "sub_categories"
  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "addressables", "shipments"
  add_foreign_key "attachments", "accounts"
  add_foreign_key "black_list_users", "accounts"
  add_foreign_key "block_users", "accounts"
  add_foreign_key "block_users", "accounts", column: "current_user_id"
  add_foreign_key "bx_block_attachment_file_attachments", "accounts"
  add_foreign_key "bx_block_profile_artist_profiles", "accounts"
  add_foreign_key "bx_block_stripe_integration_customers", "accounts"
  add_foreign_key "catalogue_reviews", "catalogues"
  add_foreign_key "catalogue_variants", "catalogue_variant_colors"
  add_foreign_key "catalogue_variants", "catalogue_variant_sizes"
  add_foreign_key "catalogue_variants", "catalogues"
  add_foreign_key "catalogues", "brands"
  add_foreign_key "catalogues", "categories"
  add_foreign_key "catalogues", "sub_categories"
  add_foreign_key "catalogues_tags", "catalogue_tags"
  add_foreign_key "catalogues_tags", "catalogues"
  add_foreign_key "categories_sub_categories", "categories"
  add_foreign_key "categories_sub_categories", "sub_categories"
  add_foreign_key "chat_messages", "accounts"
  add_foreign_key "chat_messages", "chats"
  add_foreign_key "cod_values", "shipments"
  add_foreign_key "comments", "accounts"
  add_foreign_key "deliveries", "shipments"
  add_foreign_key "delivery_address_orders", "delivery_addresses"
  add_foreign_key "delivery_address_orders", "order_management_orders"
  add_foreign_key "delivery_addresses", "accounts"
  add_foreign_key "dimensions", "items"
  add_foreign_key "email_notifications", "notifications"
  add_foreign_key "items", "shipments"
  add_foreign_key "notifications", "accounts"
  add_foreign_key "order_items", "catalogue_variants"
  add_foreign_key "order_items", "catalogues"
  add_foreign_key "order_items", "order_management_orders"
  add_foreign_key "order_transactions", "accounts"
  add_foreign_key "order_transactions", "order_management_orders"
  add_foreign_key "pickups", "shipments"
  add_foreign_key "posts", "categories"
  add_foreign_key "push_notifications", "accounts"
  add_foreign_key "recurring_subscriptions", "accounts"
  add_foreign_key "seller_accounts", "accounts"
  add_foreign_key "settings", "accounts"
  add_foreign_key "shipment_values", "shipments"
  add_foreign_key "shipments", "create_shipments"
  add_foreign_key "sub_categories", "categories"
  add_foreign_key "taggings", "tags"
  add_foreign_key "user_careers", "accounts"
  add_foreign_key "user_categories", "accounts"
  add_foreign_key "user_categories", "categories"
  add_foreign_key "user_educations", "accounts"
  add_foreign_key "user_links", "accounts"
  add_foreign_key "user_skill_sub_categories", "user_skills"
  add_foreign_key "user_skills", "accounts"
  add_foreign_key "user_sub_categories", "accounts"
  add_foreign_key "user_sub_categories", "sub_categories"
end
