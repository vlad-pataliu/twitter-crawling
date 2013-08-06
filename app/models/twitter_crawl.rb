class TwitterCrawl
  include Mongoid::Document
  
  field :name,          type: String
  field :username,      type: String
  field :user_location, type: String
  field :artist,		type: Hash
  field :track,			type: Hash

  field :artist_tags,	type: Array
end