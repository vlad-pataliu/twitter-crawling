class TwitterCrawl
  include Mongoid::Document
  
  field :name,          type: String
  field :username,      type: String
  field :user_location, type: String
  field :artist_name,   type: String
  field :song_name,     type: String
end