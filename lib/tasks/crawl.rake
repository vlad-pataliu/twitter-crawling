require 'open-uri'
url = "https://twitter.com/search/realtime?q=soundtracking&src=typd"
doc = Nokogiri::HTML(open(url))
tweets = doc.at_css(".tweet-text").text

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

name = doc.at_css(".show-popup-with-id").text

username = doc.at_css(".js-action-profile-name b").text

tweet_elements = tweets.split

hash = Hash[tweet_elements.map.with_index.to_a]

b = tweet_elements.grep(/^\"/)

c = b[0]

deleteFromArray(tweet_elements, c, hash)

tweet_elements[0] = c[1..c.length]

song_name = []

e = tweet_elements.grep(/\"/)

f = e[0]

ash = Hash[tweet_elements.map.with_index.to_a]

addInArray(tweet_elements, f, ash, song_name)

song_name_length = song_name.length()

song_name[song_name_length - 1] = f[0..(f.length - 2)]

the_song_name = song_name.join(" ")

tweet_elements.delete_at(0)

artist_name_location = []

g = tweet_elements.grep(/^http:/)

h = g[0]

theHash = Hash[tweet_elements.map.with_index.to_a]

addInArrayMinus(tweet_elements, h, theHash, artist_name_location)

tweet_elements_length = tweet_elements.length()

for counter in 0..tweet_elements_length
	tweet_elements.delete_at(0)
end

anotherHash = Hash[artist_name_location.map.with_index.to_a]

i = artist_name_location.grep(/^\(@/)

if i.length == 0
	p = artist_name_location.grep(/[@]/)
	if p.length == 0
		artist_name = artist_name_location
		the_artist_name = artist_name.join(" ")
	else
		# access the link and take name
		puts "asdadsa"
	end

else
	j = i[0]

	artist_name = []

	addInArrayMinus(artist_name_location, j, anotherHash, artist_name)

	artist_name_location.delete_at(0)

	theAnotherHash = Hash[artist_name_location.map.with_index.to_a]

	k = artist_name_location.grep(/[)]/)

	l = k[0]

	user_location = []

	addInArray(artist_name_location, l, theAnotherHash, user_location)

	user_location_length = user_location.length()

	user_location[(user_location_length - 1)] = l[0..(l.length - 2)]

	the_user_location = user_location.join(" ")

	y = artist_name.grep(/[@]/)
	z = y[0]

	the_artist_name = []

	artist_name.each do |a|
		if a.eql? z
			# access the link and take name
			puts "abcse"
		else
			the_artist_name = artist_name.join(" ")
		end
	end
end