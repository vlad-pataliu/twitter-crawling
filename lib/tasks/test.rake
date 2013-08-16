require 'open-uri'

desc "Crawl Twitter"
namespace :tCrawler do
	task :fetch => :environment do
		url = "https://twitter.com/search/realtime?q=soundtracking&src=typd"
		previousTweet = ""

		# Continue taking tweets
		while true
			sleep 10
			artist_name = []

			@name, @username, @user_location, @artist_name, @song_name = " "

			tweets = Twitter.search("soundtracking by -rt", { lang: 'en', count: 100, result_type: 'recent' } )
      tweets.statuses.map do |tweetz|
        tweet = tweetz.text

				if tweet != previousTweet
					previousTweet = tweet
					puts " "
					puts "#{tweet} \n"

					# Get user info
					getUserInfo(tweetz, tweet)

					# Get song name
					getSongInfo(tweet)
				
					if TwitterCrawl.where(name: "#{@name}", artist: { name:"#{@artist_name}" } ).exists? == false
						# Add songs to database only if the name of the artist and song is present.
						add_to_db(@name, @username, @user_location, @artist_name, @song_name) unless @artist_name.nil? && @song_name.nil?
					end
				end
			end
		end
	end
end

# Method to get info about the user
def getUserInfo(tweetz, tweet)
	@username = tweetz.user.username
	puts "Username: #{@username}"

	@name = tweetz.user.name
	puts "Name: #{@name}"

	@user_location = tweet[/\([\s]*@([^\)]+)\)/i]
	@user_location = @user_location[3..(@user_location.length - 2)] unless @user_location.nil?
	puts "User Location: #{@user_location}"
end

# Method to get info about the song
def getSongInfo(tweet)
	the_artist_name = tweet[/by[\w\W]+(((http\:\/\/){1}))/i]
	if !the_artist_name.nil?
		@artist_name = the_artist_name[/(?<=^|(?<=[^a-zA-Z0-9\_\.]))@([A-Za-z0-9\_]+)/i]
		if !@artist_name.nil?
			@artist_name = @artist_name[1..@artist_name.length]
			puts @artist_name
			# Catch the exception thrown by trying to get information
			# from the artist tweet page info. The most common exception
			# is the Timeout/execution expired.
			begin
				userTweet = Twitter.user("#{@artist_name}").verified
			rescue 	
				puts "Exception caught and ignored on verified"
				sleep 15
				return
			end
			if !userTweet.nil? && userTweet == true
				# Catch the exception thrown by trying to get information
				# from the artist tweet page info. The most common exception
				# is the Timeout/execution expired.
				begin
					@artist_name = Twitter.user("#{@artist_name}").name
				rescue
					puts "Exception caught and ignored on name"
					sleep 15
					return
				end
			end	
		else
			@user_location = tweet[/\([\s]*@([^\)]+)\)/i]
			if @user_location.nil?
				@artist_name = the_artist_name[3..(the_artist_name.length - 9)]
			else
				@artist_name = tweet[/by[\w\W]+[(@]/i]
				@artist_name = @artist_name[3..(@artist_name.length - 3)] unless @artist_name.nil?
			end
		end	

		the_name = @artist_name[/[\w\W]+[|]/i]
		@artist_name = the_name[0..(the_name.length - 2)] unless the_name.nil?
		puts "Artist name: #{@artist_name}"

		@song_name = tweet[/\"[\s\S\d\D\w\W]+\"/i]
		if !@song_name.nil?
			the_song = @song_name[/[\w\W\d\D\s\S"] +"[\w\W\d\D\s\S]+\w/i]
			@song_name = !the_song.nil? ? the_song[3..(the_song.length)] : @song_name[1..(@song_name.length - 2)]
			puts "Song name: #{@song_name}"
		end
	end
end

# Method to save all the information in the database
def add_to_db(name, username, user_location, artist_name, song_name)
	TwitterCrawl.create { |twitter|
		twitter.name = @name
		twitter.username = @username
		twitter.user_location = @user_location
		twitter.artist = { name: @artist_name }
  	twitter.track = { title: @song_name }
  }
end