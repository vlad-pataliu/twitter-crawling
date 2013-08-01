require 'nokogiri'
require 'open-uri'

# In order to parse the tweets, use the following regex:
# Artist:
# 			--> twitter handle: tweets[/(?<=^|(?<=[^a-zA-Z0-9\_\.]))@([A-Za-z0-9\_]+)/i]
# 			--> name: 					tweets[/by[\w\W]+(((http\:\/\/){1}))/i], then test if tweets.index("( @") exists
# Song title: 		tweets[/\"[\s\S\d\D\w\W]+\"/i]
# Location: 			tweets[/\([\s]@([^\)]+)\)/i]

url = "https://twitter.com/search/realtime?q=soundtracking&src=typd"

desc "Crawl Twitter"
namespace :crawler do
	task :fetch_songs => :environment do
		
		# Variable to count how manu tweets to add into the array of tweets
		previousTweet = ""

		# Continue taking tweets
		while true
			doc = Nokogiri::HTML(open(url))

			tweet = doc.at_css(".tweet-text").text
			artist_name = []

			if tweets != previousTweet
				previousTweet = tweets
				puts "#{tweets} \n"

				# Take the real name of the user
				name = doc.at_css(".show-popup-with-id").text
				puts "Name: #{name}"

				# Take the username of the user
				username = doc.at_css(".js-action-profile-name b").text
				puts "Username: #{username}"

				tweet_elements = tweet.split

				hash = Hash[tweet_elements.map.with_index.to_a]

				# Search by "\" (begining of the song name)
				beginingOfTheSong = tweet_elements.grep(/^\"/)
				elementAtTheBeginingOfTheSong = beginingOfTheSong[0]

				# If no artist is found, take the next tweet
				if elementAtTheBeginingOfTheSong.present?
					# Delete everything that is before that
					deleteFromArray(tweet_elements, elementAtTheBeginingOfTheSong, hash)
					tweet_elements[0] = elementAtTheBeginingOfTheSong[1..elementAtTheBeginingOfTheSong.length]
					song_name = []

					# Search by "\" again (end of the song name)
					endOfTheSong = tweet_elements.grep(/\"/)
					elementAtTheEndOfTheSong = endOfTheSong[0]
					ash = Hash[tweet_elements.map.with_index.to_a]

					# Add the song name into an array
					addInArray(tweet_elements, elementAtTheEndOfTheSong, ash, song_name)
					song_name_length = song_name.length()
					song_name[song_name_length - 1] = elementAtTheEndOfTheSong[0..(elementAtTheEndOfTheSong.length - 2)]
					the_song_name = song_name.join(" ")
					puts "Song name: " + the_song_name
					tweet_elements.delete_at(0)
					artist_name_location = []

					# Search by "http:"
					pageLink = tweet_elements.grep(/^http:/)
					pageLinkFirstElement = pageLink[0]
					theHash = Hash[tweet_elements.map.with_index.to_a]

					# Delete the 'http:' string
					addInArrayMinus(tweet_elements, pageLinkFirstElement, theHash, artist_name_location)
					tweet_elements_length = tweet_elements.length()

					# Delete all the elements starting with the 'http', if any
					for counter in 0..tweet_elements_length
						tweet_elements.delete_at(0)
					end	

					anotherHash = Hash[artist_name_location.map.with_index.to_a]
					userLocation = artist_name_location.grep(/^\(@/)

					if userLocation.length == 0
						artistLinkName = artist_name_location.grep(/[@]/)
						if artistLinkName.length == 0
							the_artist_name = artist_name_location.join(" ")
						else
							the_artist_name == Twitter.user("#{artistLinkName}").name
						end
					puts "Artist name: #{the_artist_name}"
					puts " "

					else
						userLocationFirstElement = userLocation[0]
						artist_name = []
						addInArrayMinus(artist_name_location, userLocationFirstElement, anotherHash, artist_name)
						puts artist_name.length
						artist_name_location.delete_at(0)
						theAnotherHash = Hash[artist_name_location.map.with_index.to_a]
						userLocationEnd = artist_name_location.grep(/[)]/)
						userLocationEndFirstElement = userLocationEnd[0]
						user_location = []
						addInArray(artist_name_location, userLocationEndFirstElement, theAnotherHash, user_location)
						user_location_length = user_location.length()
						user_location[(user_location_length - 1)] = userLocationEndFirstElement[0..(userLocationEndFirstElement.length - 2)]
						the_user_location = user_location.join(" ")
						puts "User location: " + the_user_location
						artistNameLink = artist_name.grep(/[@]/)
						artistNameLinkFirstElement = artistNameLink[0]
						puts "asdasdad #{artistNameLinkFirstElement}"
						if artistNameLinkFirstElement != nil
							artist_name.each do |arrayString|
								if arrayString.eql? artistNameLinkFirstElement
									the_artist_name == Twitter.user("#{artistNameLinkFirstElement}").name
								else
									the_artist_name = artist_name.join(" ")
								end
							end
							puts "Artist name: #{the_artist_name}"
							puts " "
						else
							previousTweet = previousTweet
							puts " "
						end
					end
				end

				# Add to database
				add_to_db(name, username, the_song_name, the_artist_name, the_user_location)
			end
		end
	end
end

# Method to delete everything that is before a certain string
def deleteFromArray(initialArray, aString, aHash)
	initialArray.each do |arrayString|
		if arrayString.eql? aString
			index = aHash[aString] - 1
			for counter in 0..index
				initialArray.delete_at(0)
			end
		end
	end
end

# Method to delete and add into another array upon a certain string, containing it
def addInArray(initialArray, aString, aHash, anArray)
	initialArray.each do |arrayString|
		if arrayString.eql? aString
			index = aHash[aString]
			for counter in 0..index
				anArray.push(initialArray.delete_at(0))
			end
		end
	end
end

# Method to delete and add into another array upon a certain string, without containing it
def addInArrayMinus(initialArray, aString, aHash, anArray)
	initialArray.each do |arrayString|
		if arrayString.eql? aString
			index = aHash[aString] - 1
			for counter in 0..index
				anArray.push(initialArray.delete_at(0))
			end
		end
	end
end

# Method to save all the information in the database
def add_to_db(name, username, the_song_name, the_artist_name, the_user_location)
	TwitterCrawl.create(
		name: name,
		username: username,
		song_name: the_song_name,
		artist_name: the_artist_name,
		user_location: the_user_location 
	)
end