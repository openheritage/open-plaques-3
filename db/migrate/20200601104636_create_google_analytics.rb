class CreateGoogleAnalytics < ActiveRecord::Migration[6.0]
  def change
    create_table :google_analytics do |t|
      t.string     :page,        null: false
      t.string     :period,      null: false
      t.references :record,      null: false, polymorphic: true, index: false
      t.bigint     :page_views,  null: false
      t.bigint     :unique_page_views
      t.float      :average_time_on_page
      t.bigint     :entrances
      t.float      :bounce_rate
      t.float      :exit_percentage

      t.datetime :created_at, null: false

      t.index [ :record_type, :record_id, :page, :period ], name: "index_ga_uniqueness", unique: true
    end
  end
end
