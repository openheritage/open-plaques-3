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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180107092748) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "areas", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "dbpedia_uri", limit: 255
    t.integer "country_id"
    t.string "slug", limit: 255
    t.float "latitude"
    t.float "longitude"
    t.integer "plaques_count"
    t.index ["country_id"], name: "index_areas_on_country_id"
    t.index ["name"], name: "index_areas_on_name"
    t.index ["slug"], name: "index_areas_on_slug"
  end

  create_table "colours", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.integer "plaques_count"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "dbpedia_uri", limit: 255
    t.boolean "common", default: false, null: false
    t.string "slug", limit: 255
    t.index ["slug"], name: "index_colours_on_slug"
  end

  create_table "countries", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.string "alpha2", limit: 255
    t.integer "areas_count"
    t.integer "plaques_count"
    t.string "dbpedia_uri", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "description"
  end

  create_table "languages", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.string "alpha2", limit: 255
    t.integer "plaques_count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "licences", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.string "url", limit: 255
    t.boolean "allows_commercial_use"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "photos_count"
    t.string "abbreviation", limit: 255
  end

  create_table "organisations", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.string "website", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "notes"
    t.string "slug", limit: 255
    t.text "description"
    t.integer "sponsorships_count", default: 0
    t.float "latitude"
    t.float "longitude"
    t.integer "language_id"
    t.index ["name"], name: "index_organisations_on_name"
    t.index ["slug"], name: "index_organisations_on_slug"
  end

  create_table "pages", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.string "slug", limit: 255
    t.text "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "strapline", limit: 255
  end

  create_table "people", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.date "born_on"
    t.date "died_on"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "personal_connections_count"
    t.integer "personal_roles_count"
    t.string "index", limit: 255
    t.boolean "born_on_is_circa"
    t.boolean "died_on_is_circa"
    t.string "surname_starts_with", limit: 255
    t.text "introduction"
    t.string "gender", limit: 255, default: "u"
    t.text "aka", default: [], array: true
    t.string "find_a_grave_id", limit: 255
    t.string "ancestry_id", limit: 255
    t.string "wikidata_id"
    t.index ["born_on", "died_on"], name: "born_and_died"
    t.index ["index"], name: "index_people_on_index"
    t.index ["surname_starts_with"], name: "index_people_on_surname_starts_with"
  end

  create_table "personal_connections", id: :serial, force: :cascade do |t|
    t.integer "person_id"
    t.integer "verb_id"
    t.integer "plaque_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "started_at"
    t.datetime "ended_at"
    t.integer "plaque_connections_count"
    t.index ["person_id"], name: "index_personal_connections_on_person_id"
    t.index ["plaque_id"], name: "index_personal_connections_on_plaque_id"
    t.index ["verb_id"], name: "index_personal_connections_on_verb_id"
  end

  create_table "personal_roles", id: :serial, force: :cascade do |t|
    t.integer "person_id"
    t.integer "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date "started_at"
    t.date "ended_at"
    t.integer "related_person_id"
    t.integer "ordinal"
    t.boolean "primary"
    t.index ["person_id"], name: "index_personal_roles_on_person_id"
    t.index ["related_person_id"], name: "index_personal_roles_on_related_person_id"
    t.index ["role_id"], name: "index_personal_roles_on_role_id"
  end

  create_table "photos", id: :serial, force: :cascade do |t|
    t.string "photographer", limit: 255
    t.string "url", limit: 255
    t.integer "plaque_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "file_url", limit: 255
    t.integer "licence_id"
    t.string "photographer_url", limit: 255
    t.datetime "taken_at"
    t.string "shot", limit: 255
    t.boolean "of_a_plaque", default: true
    t.string "latitude", limit: 255
    t.string "longitude", limit: 255
    t.string "subject", limit: 255
    t.text "description"
    t.string "thumbnail", limit: 255
    t.integer "person_id"
    t.integer "clone_id"
    t.integer "nearest_plaque_id"
    t.integer "distance_to_nearest_plaque"
    t.index ["licence_id"], name: "index_photos_on_licence_id"
    t.index ["person_id"], name: "index_photos_on_person_id"
    t.index ["photographer"], name: "index_photos_on_photographer"
    t.index ["plaque_id"], name: "index_photos_on_plaque_id"
  end

  create_table "picks", id: :serial, force: :cascade do |t|
    t.integer "plaque_id"
    t.text "description"
    t.datetime "feature_on"
    t.datetime "last_featured"
    t.integer "featured_count"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "proposer", limit: 255
  end

  create_table "plaques", id: :serial, force: :cascade do |t|
    t.date "erected_at"
    t.float "latitude"
    t.float "longitude"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "inscription"
    t.string "reference", limit: 255
    t.text "notes"
    t.text "parsed_inscription"
    t.integer "colour_id"
    t.integer "photos_count", default: 0, null: false
    t.integer "language_id"
    t.text "description"
    t.boolean "inscription_is_stub", default: false
    t.integer "personal_connections_count", default: 0
    t.integer "series_id"
    t.boolean "is_accurate_geolocation", default: true
    t.boolean "is_current", default: true
    t.text "inscription_in_english"
    t.string "series_ref", limit: 255
    t.string "address", limit: 255
    t.integer "area_id"
    t.index ["area_id"], name: "index_plaques_on_area_id"
    t.index ["colour_id"], name: "index_plaques_on_colour_id"
    t.index ["latitude", "longitude"], name: "geo"
    t.index ["series_id"], name: "index_plaques_on_series_id"
  end

  create_table "roles", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "personal_roles_count"
    t.string "index", limit: 255
    t.string "slug", limit: 255
    t.string "role_type", limit: 255
    t.string "abbreviation", limit: 255
    t.string "prefix", limit: 255
    t.string "suffix", limit: 255
    t.text "description"
    t.integer "priority"
    t.string "wikidata_id"
    t.index ["index"], name: "starts_with"
    t.index ["role_type"], name: "index_roles_on_role_type"
    t.index ["slug"], name: "index_roles_on_slug"
  end

  create_table "series", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.string "description", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "plaques_count"
    t.float "latitude"
    t.float "longitude"
  end

  create_table "sponsorships", id: :serial, force: :cascade do |t|
    t.integer "organisation_id"
    t.integer "plaque_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["organisation_id"], name: "index_sponsorships_on_organisation_id"
    t.index ["plaque_id"], name: "index_sponsorships_on_plaque_id"
  end

  create_table "todo_items", id: :serial, force: :cascade do |t|
    t.string "description", limit: 255
    t.string "action", limit: 255
    t.string "url", limit: 255
    t.string "image_url", limit: 255
    t.integer "plaque_id"
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "username", limit: 40
    t.string "name", limit: 100
    t.string "email", limit: 100
    t.string "crypted_password", limit: 40
    t.string "salt", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "remember_token_expires_at"
    t.boolean "is_admin"
    t.string "encrypted_password", limit: 128, null: false
    t.string "reset_password_token", limit: 255
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip", limit: 255
    t.string "last_sign_in_ip", limit: 255
    t.boolean "is_verified", default: false, null: false
    t.boolean "opted_in", default: false
    t.datetime "reset_password_sent_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "verbs", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "personal_connections_count"
  end

end
