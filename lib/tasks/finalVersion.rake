require 'nokogiri'
require 'open-uri'

url = "https://twitter.com/search/realtime?q=soundtracking&src=typd"

desc "Crawl Twitter"
namespace :crawler do
	task :fetch => :environment do
		# Variable to count how manu tweets to add into the array of tweets
		previousTweet = ""

		# Continue taking tweets
		while true
			@name, @username, @user_location, @artist_name, @song_name = " "
			doc = Nokogiri::HTML(open(url))

			tweet = doc.at_css(".tweet-text").text
			artist_name = []

			if tweet != previousTweet
				previousTweet = tweet
				puts " "
				puts "#{tweet} \n"

				# Get user info
				getUserInfo(doc, tweet)

				#Get song name
				getSongInfo(tweet)
				
				# Add songs to database
				add_to_db(@name, @username, @user_location, @artist_name, @song_name)
			end
		end
	end
end

# Method to get info about the user
def getUserInfo(doc, tweet)
	@name = doc.at_css(".show-popup-with-id").text
	puts "Name: #{@name}"

	@username = doc.at_css(".js-action-profile-name b").text
	puts "Username: #{@username}"

	@user_location = tweet[/\([\s]*@([^\)]+)\)/i]
	if @user_location != nil
		@user_location = @user_location[3..(@user_location.length - 2)]
		puts "User Location: #{@user_location}"
	end
end

# Method to get info about the song
def getSongInfo(tweet)
	the_artist_name = tweet[/by[\w\W]+(((http\:\/\/){1}))/i]
	if the_artist_name != nil
		@artist_name = tweet[/(?<=^|(?<=[^a-zA-Z0-9\_\.]))@([A-Za-z0-9\_]+)/i]
		if @artist_name != nil
			@artist_name = @artist_name[1..@artist_name.length]
			if Twitter.user("#{@artist_name}").verified == true
				@artist_name = Twitter.user("#{@artist_name}").name
			end
		else
			@user_location = tweet[/\([\s]*@([^\)]+)\)/i]
			if @user_location == nil
				@artist_name = the_artist_name[3..(the_artist_name.length - 9)]
			else
				@artist_name = tweet[/by[\w\W]+[(@]/i]
				if @artist_name != nil	
					@artist_name = @artist_name[3..(@artist_name.length - 3)]
				end
			end
		end	
		puts "Artist name: #{@artist_name}"

		@song_name = tweet[/\"[\s\S\d\D\w\W]+\"/i]
		if @song_name != nil
			@song_name = @song_name[1..(@song_name.length - 2)]
			puts "Song name: #{@song_name}"
		end
	end
end

# Method to save all the information in the database
def add_to_db(name, username, user_location, artist_name, song_name)
	TwitterCrawl.create(
		name: @name,
		username: @username,
		user_location: @user_location,
		artist_name: @artist_name,
		song_name: @song_name
	)
end