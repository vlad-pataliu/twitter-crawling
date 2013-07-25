desc "Crawl Twitter"
namespace :crawler do
	task :fetch_songs => :environment do
		require 'nokogiri'
		require 'open-uri'

		url = "https://twitter.com/search?q=soundtracking&src=typd"
		doc = Nokogiri::HTML(open(url))
		tweet = doc.at_css(".tweet-text").text	
	end
end

# or
tweet_elements.select{|x|x[/^\"/]}

# delete first 'index' elements from the list
tweet_elements.each do |a|
	if a.eql? "by"
		index = hash["by"]
		for counter in 0..index
			tweet_elements.delete_at(0)
		end
	end
end

tweet_elements.each do |a|
	b = tweet_elements.grep(/^\"/)
	c = b[0]
	if a.eql? c[1..c.length]
		index = hash[c[1..c.length]]
		for counter in 0..index
			tweet_elements.delete_at(0)
		end
	end
end


# maybe
tweet_elements.each do |a|
	puts a
	b = tweet_elements.grep(/^\"/)
	c = b[0]
	if a.eql? c[1..c.length]
		index = hash[c[1..c.length]]
		for counter in 0..index
			tweet_elements.delete_at(0)
		end
	end
end

################### correct ###################

### () test ###
aTweet = "My soundtrack: ♫ \"Lead Me to the Rock\" by Stephen Hurd (@ Rialto, CA, USA) http://sdtk.fm/13GKjQC " 

require 'open-uri'
url = "https://twitter.com/search/realtime?q=soundtracking&src=typd"
doc = Nokogiri::HTML(open(url))
tweets = doc.at_css(".tweet-text").text
name = doc.at_css(".show-popup-with-id").text
username = doc.at_css(".js-action-profile-name b").text
tweet_elements = tweets.split

# assign a key to each array element
hash = Hash[tweet_elements.map.with_index.to_a]

def deleteFromArray(initialArray, aString, aHash)
	initialArray.each do |a|
		if a.eql? aString
			index = aHash[aString] - 1
			for counter in 0..index
				initialArray.delete_at(0)
			end
		end
	end
end

def addInArray(initialArray, aString, aHash, anArray)
	initialArray.each do |a|
		if a.eql? aString
			index = aHash[aString]
			for counter in 0..index
				anArray.push(initialArray.delete_at(0))
			end
		end
	end
end

def addInArrayMinus(initialArray, aString, aHash, anArray)
	initialArray.each do |a|
		if a.eql? aString
			index = aHash[aString] - 1
			for counter in 0..index
				anArray.push(initialArray.delete_at(0))
			end
		end
	end
end

b = tweet_elements.grep(/^\"/)
c = b[0]

deleteFromArray(tweet_elements, c, hash)

# tweet_elements.each do |a|
# 	if a.eql? c
# 		index = hash[c] - 1
# 		for counter in 0..index
# 			tweet_elements.delete_at(0)
# 		end
# 	end
# end

tweet_elements[0] = c[1..c.length]

song_name = []
e = tweet_elements.grep(/\"/)
f = e[0]

ash = Hash[tweet_elements.map.with_index.to_a]

addInArray(tweet_elements, f, ash, song_name)

# tweet_elements.each do |a|
# 	if a.eql? f
# 		index = ash[f]
# 		for counter in 0..index
# 			song_name.push(tweet_elements.delete_at(0))
# 		end
# 	end
# end	

song_name_length = song_name.length()

length_of_song_name = song_name_length - 1

song_name[length_of_song_name] = f[0..(f.length - 2)]

the_song_name = song_name.join(" ")

# remove "by"
tweet_elements.delete_at(0)

artist_name_location = []
g = tweet_elements.grep(/^http:/)
h = g[0]

theHash = Hash[tweet_elements.map.with_index.to_a]

addInArrayMinus(tweet_elements, h, theHash, artist_name_location)

# tweet_elements.each do |a|
# 	if a.eql? h
# 		index = theHash[h] - 1
# 		for counter in 0..index
# 			artist_name_location.push(tweet_elements.delete_at(0))
# 		end
# 	end
# end

# delete everything remained in 'tweet_elements' array
tweet_elements.delete_at(0)

anotherHash = Hash[artist_name_location.map.with_index.to_a]

i = artist_name_location.grep(/@/)
j = i[0]
artist_name = []

addInArrayMinus(artist_name_location, j, anotherHash, artist_name)

# artist_name_location.each do |a|
# 	if a.eql? j
# 		index = anotherHash[j] - 1
# 		for counter in 0..index
# 			artist_name.push(artist_name_location.delete_at(0))
# 		end
# 	end
# end

the_artist_name = artist_name.join(" ")

artist_name_location.delete_at(0)

theAnotherHash = Hash[artist_name_location.map.with_index.to_a]

k = artist_name_location.grep(/[)]/)
l = k[0]
user_location = []

addInArray(artist_name_location, l, theAnotherHash, user_location)

# artist_name_location.each do |a|
# 	if a.eql? l
# 		index = theAnotherHash[l]
# 		for counter in 0..index
# 			user_location.push(artist_name_location.delete_at(0))
# 		end
# 	end
# end

user_location_length = user_location.length()

user_location[(user_location_length - 1)] = l[0..(l.length - 2)]

the_user_location = user_location.join(" ")

##### for @ artists #####
.twitter-atreply b