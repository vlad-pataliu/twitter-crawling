#require "base64"

desc "URL encoding"
namespace :url do
  task :encoding, :arg1 do |t, args|
  	argument = args.arg1

    base49 = ([*0..9,*'a'..'z',*'A'..'Z'] - %w[a e i o u A E I O U 0 1 3]).join

  	if argument.is_number?
  		#initial_id = argument.to_s
      initial_id = argument.to_i
      initial_id *= 1000000
  		#id_encoded = Base64.encode64(initial_id)
      id_encoded = AnyBase.encode( initial_id, base49 )
  		puts "The encoded value of the moment id is: #{id_encoded}"
  	
  	else
  		encoded_url = argument.to_s
  		#decoded_url = Base64.decode64(encoded_url)
      decoded_url = AnyBase.decode( encoded_url, base49 )
      decoded_url /= 1000000
  		puts "The id of the moment is: #{decoded_url}"
  	end
	end
end

public

# Check if the argument is a number or not
def is_number?
  self.to_f.to_s == self.to_s || self.to_i.to_s == self.to_s
end

module AnyBase
  ENCODER = Hash.new do |h,k|
    h[k] = Hash[ k.chars.map.with_index.to_a.map(&:reverse) ]
  end
  DECODER = Hash.new do |h,k|
    h[k] = Hash[ k.chars.map.with_index.to_a ]
  end

  def self.encode( value, keys )
    ring = ENCODER[keys]
    base = keys.length
    result = []
    until value == 0
      result << ring[ value % base ]
      value /= base
    end
    result.reverse.join
  end

  def self.decode( string, keys )
    ring = DECODER[keys]
    base = keys.length
    string.reverse.chars.with_index.inject(0) do |sum,(char,i)|
      sum + ring[char] * base**i
    end
  end
end