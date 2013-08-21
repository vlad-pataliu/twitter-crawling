class TwitterCrawl
  include Mongoid::Document
  
  field :text,     type: String
  field :name,     type: String
  field :username, type: String
  field :location, type: String
  field :date,     type: Time
  field :song,		 type: Hash
  field :tags,	   type: Array
end