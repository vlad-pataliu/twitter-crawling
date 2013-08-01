class TwitterCrawlingDb
  include Mongoid::Document
  # include Mongoid::ActiveRecordBridge

  field :name,          type: String
  field :username,      type: String
  field :song_name,     type: String
  field :artist_name,   type: String
  field :user_location, type: String

end