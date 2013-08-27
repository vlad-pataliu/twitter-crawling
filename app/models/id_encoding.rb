class IdEncoding
  include Mongoid::Document
  
  field :id,     	type: Integer
  field :encoded,	type: String
end