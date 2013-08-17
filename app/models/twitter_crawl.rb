class TwitterCrawl
  include Mongoid::Document
  
  field :name,            type: String
  field :username,        type: String
  field :user_location,   type: String
  field :date,            type: Time
  field :song,		        type: Hash
  field :location,        type: Hash
  field :tags,	          type: Array
end