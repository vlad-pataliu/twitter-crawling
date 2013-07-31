require 'nokogiri'
require 'open-uri'

url = "https://twitter.com/search/realtime?q=soundtracking&src=typd"

desc "Crawl Twitter"
namespace :crawler do
	task :fetch_songs => :environment do
		
		# Variable to count how manu tweets to add into the array of tweets
		previousTweet = ""

		# Continue taking tweets
		while true
			doc = Nokogiri::HTML(open(url))
			tweets = doc.at_css(".tweet-text").text
			artist_name = []

			if tweets == previousTweet
				tweets = previousTweet
			else
				previousTweet = tweets
				puts tweets
				puts " "

				# Take the real name of the user
				name = doc.at_css(".show-popup-with-id").text
				puts "Name: " + name

				# Take the username of the user
				username = doc.at_css(".js-action-profile-name b").text
				puts "Username: " + username

				tweet_elements = tweets.split
				hash = Hash[tweet_elements.map.with_index.to_a]

				# Search by "\" (begining of the song name)
				beginingOfTheSong = tweet_elements.grep(/^\"/)
				elementAtTheBeginingOfTheSong = beginingOfTheSong[0]

				if elementAtTheBeginingOfTheSong == nil
					previousTweet = previousTweet
					puts " "
				else	
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

					for counter in 0..tweet_elements_length
						tweet_elements.delete_at(0)
					end	

					anotherHash = Hash[artist_name_location.map.with_index.to_a]
					userLocation = artist_name_location.grep(/^\(@/)

					if userLocation.length == 0
						artistLinkName = artist_name_location.grep(/[@]/)
						if artistLinkName.length == 0
							artist_name = artist_name_location
							the_artist_name = artist_name.join(" ")
							puts "The Artist name: " + the_artist_name
							puts " "
						else
							# access the link and take name
							the_artist_name == Twitter.user("#{artistLinkName}").name
							puts the_artist_name
						end
					else
						userLocationFirstElement = userLocation[0]
						artist_name = []
						addInArrayMinus(artist_name_location, userLocationFirstElement, anotherHash, artist_name)
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
						artist_name.each do |arrayString|
							if arrayString.eql? artistNameLinkFirstElement
								# access the link and take name
								the_artist_name == Twitter.user("#{artistNameLinkFirstElement}").name
								puts the_artist_name
							else
								the_artist_name = artist_name.join(" ")
							end
						end

						puts "Artist name: #{the_artist_name}"
						puts " "
					end
				end

				TwitterCrawl.create(
					name: name,
					username: username,
					song_name: the_song_name,
					artist_name: the_artist_name,
					user_location: the_user_location
				)
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