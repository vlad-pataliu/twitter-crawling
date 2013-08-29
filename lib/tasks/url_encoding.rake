desc "URL encoding"
namespace :url do
  task :encoding, :arg1 do |t, args|
    
  	argument = args.arg1
    hashids = Hashids.new("", 6)

  	if argument.is_number?
      initial_id = argument.to_i
      id_encoded = hashids.encrypt(initial_id)
  		puts "The encoded value of the moment id is: #{id_encoded}"
  	
  	else
  		encoded_url = argument.to_s
      decoded_url = hashids.decrypt(encoded_url)
  		puts "The id of the moment is: #{decoded_url}"
  	end
	end
end

public
# Check if the argument is a number or not
def is_number?
  self.to_f.to_s == self.to_s || self.to_i.to_s == self.to_s
end