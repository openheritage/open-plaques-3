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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150726122111) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "areas", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "woeid"
    t.string   "dbpedia_uri"
    t.integer  "country_id"
    t.string   "slug"
    t.float    "latitude"
    t.float    "longitude"
    t.integer  "plaques_count"
  end

  add_index "areas", ["country_id"], name: "index_areas_on_country_id", using: :btree
  add_index "areas", ["name"], name: "index_areas_on_name", using: :btree
  add_index "areas", ["slug"], name: "index_areas_on_slug", using: :btree

  create_table "colours", force: true do |t|
    t.string   "name"
    t.integer  "plaques_count"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "dbpedia_uri"
    t.boolean  "common",        default: false, null: false
    t.string   "slug"
  end

  add_index "colours", ["slug"], name: "index_colours_on_slug", using: :btree

  create_table "countries", force: true do |t|
    t.string   "name"
    t.string   "alpha2"
    t.integer  "areas_count"
    t.integer  "plaques_count"
    t.string   "dbpedia_uri"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
  end

  create_table "languages", force: true do |t|
    t.string   "name"
    t.string   "alpha2"
    t.integer  "plaques_count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "licences", force: true do |t|
    t.string   "name"
    t.string   "url"
    t.boolean  "allows_commercial_use"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "photos_count"
    t.string   "abbreviation"
  end

  create_table "locations", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "personal_connections_count"
    t.integer  "plaques_count"
    t.integer  "area_id"
    t.integer  "country_id"
  end

  create_table "organisations", force: true do |t|
    t.string   "name"
    t.string   "website"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "notes"
    t.string   "slug"
    t.text     "description"
    t.integer  "sponsorships_count", default: 0
    t.float    "latitude"
    t.float    "longitude"
  end

  add_index "organisations", ["name"], name: "index_organisations_on_name", using: :btree
  add_index "organisations", ["slug"], name: "index_organisations_on_slug", using: :btree

  create_table "pages", force: true do |t|
    t.string   "name"
    t.string   "slug"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "people", force: true do |t|
    t.string   "name"
    t.date     "born_on"
    t.date     "died_on"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "personal_connections_count"
    t.integer  "personal_roles_count"
    t.string   "index"
    t.boolean  "born_on_is_circa"
    t.boolean  "died_on_is_circa"
    t.string   "wikipedia_url"
    t.string   "dbpedia_uri"
    t.string   "wikipedia_paras"
    t.string   "surname_starts_with"
    t.text     "introduction"
    t.string   "gender",                     default: "u"
    t.text     "aka",                        default: [],  array: true
  end

  add_index "people", ["born_on", "died_on"], name: "born_and_died", using: :btree
  add_index "people", ["index"], name: "index_people_on_index", using: :btree
  add_index "people", ["surname_starts_with"], name: "index_people_on_surname_starts_with", using: :btree

  create_table "personal_connections", force: true do |t|
    t.integer  "person_id"
    t.integer  "verb_id"
    t.integer  "plaque_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "started_at"
    t.datetime "ended_at"
    t.integer  "plaque_connections_count"
  end

  add_index "personal_connections", ["person_id"], name: "index_personal_connections_on_person_id", using: :btree
  add_index "personal_connections", ["plaque_id"], name: "index_personal_connections_on_plaque_id", using: :btree
  add_index "personal_connections", ["verb_id"], name: "index_personal_connections_on_verb_id", using: :btree

  create_table "personal_roles", force: true do |t|
    t.integer  "person_id"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "started_at"
    t.date     "ended_at"
    t.integer  "related_person_id"
    t.integer  "ordinal"
  end

  add_index "personal_roles", ["person_id"], name: "index_personal_roles_on_person_id", using: :btree
  add_index "personal_roles", ["related_person_id"], name: "index_personal_roles_on_related_person_id", using: :btree
  add_index "personal_roles", ["role_id"], name: "index_personal_roles_on_role_id", using: :btree

  create_table "photos", force: true do |t|
    t.string   "photographer"
    t.string   "url"
    t.integer  "plaque_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "file_url"
    t.integer  "licence_id"
    t.string   "photographer_url"
    t.datetime "taken_at"
    t.string   "shot"
    t.boolean  "of_a_plaque",      default: true
    t.string   "latitude"
    t.string   "longitude"
    t.string   "subject"
    t.text     "description"
    t.string   "thumbnail"
    t.integer  "person_id"
  end

  add_index "photos", ["licence_id"], name: "index_photos_on_licence_id", using: :btree
  add_index "photos", ["photographer"], name: "index_photos_on_photographer", using: :btree
  add_index "photos", ["plaque_id"], name: "index_photos_on_plaque_id", using: :btree

  create_table "picks", force: true do |t|
    t.integer  "plaque_id"
    t.text     "description"
    t.datetime "feature_on"
    t.datetime "last_featured"
    t.integer  "featured_count"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "proposer"
  end

  create_table "plaques", force: true do |t|
    t.date     "erected_at"
    t.float    "latitude"
    t.float    "longitude"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "inscription"
    t.string   "reference"
    t.text     "notes"
    t.text     "parsed_inscription"
    t.integer  "colour_id"
    t.integer  "photos_count",               default: 0,     null: false
    t.integer  "language_id"
    t.text     "description"
    t.boolean  "inscription_is_stub",        default: false
    t.integer  "personal_connections_count", default: 0
    t.integer  "series_id"
    t.boolean  "is_accurate_geolocation",    default: true
    t.boolean  "is_current",                 default: true
    t.text     "inscription_in_english"
    t.string   "series_ref"
    t.string   "address"
    t.integer  "area_id"
  end

  add_index "plaques", ["area_id"], name: "index_plaques_on_area_id", using: :btree
  add_index "plaques", ["colour_id"], name: "index_plaques_on_colour_id", using: :btree
  add_index "plaques", ["latitude", "longitude"], name: "geo", using: :btree
  add_index "plaques", ["series_id"], name: "index_plaques_on_series_id", using: :btree

  create_table "roles", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "personal_roles_count"
    t.string   "index"
    t.string   "slug"
    t.string   "wikipedia_stub"
    t.string   "role_type"
    t.string   "abbreviation"
    t.string   "prefix"
    t.string   "suffix"
    t.text     "description"
  end

  add_index "roles", ["index"], name: "starts_with", using: :btree
  add_index "roles", ["role_type"], name: "index_roles_on_role_type", using: :btree
  add_index "roles", ["slug"], name: "index_roles_on_slug", using: :btree

  create_table "series", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "plaques_count"
  end

  create_table "sponsorships", force: true do |t|
    t.integer  "organisation_id"
    t.integer  "plaque_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sponsorships", ["organisation_id"], name: "index_sponsorships_on_organisation_id", using: :btree
  add_index "sponsorships", ["plaque_id"], name: "index_sponsorships_on_plaque_id", using: :btree

  create_table "todo_items", force: true do |t|
    t.string   "description"
    t.string   "action"
    t.string   "url"
    t.string   "image_url"
    t.integer  "plaque_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "username",                  limit: 40
    t.string   "name",                      limit: 100
    t.string   "email",                     limit: 100
    t.string   "crypted_password",          limit: 40
    t.string   "salt",                      limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "remember_token_expires_at"
    t.boolean  "is_admin"
    t.integer  "plaques_count"
    t.string   "encrypted_password",        limit: 128,                 null: false
    t.string   "reset_password_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.boolean  "is_verified",                           default: false, null: false
    t.boolean  "opted_in",                              default: false
    t.datetime "reset_password_sent_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

  create_table "verbs", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "personal_connections_count"
  end

end
