require 'nokogiri'
require 'open-uri'

# TODO: Update task so that it will run the query against any argument
desc "Crawl Twitter"
namespace :twitter do
  task :crawler => :environment do
    q ||= 'soundtracking'
    url = "https://twitter.com/search/realtime?q=#{q}&src=typd"
    previousTweet, @artist, @title = ''

    while true
      puts "Listening for new #{q} tweets..."
      results = get_search_results(url)
      next unless results

      tweet = results.at_css(".tweet-text").text
      if tweet != previousTweet
        previousTweet = tweet
        puts "\n\nNew tweet:\n------------------------\n"
        puts "Tweet text:\n#{tweet}\n\n"

        name = results.at_css('.show-popup-with-id').text
        username = results.at_css('.js-action-profile-name b').text
        
        location = tweet[/\([\s]*@([^\)]+)\)/i]
        location = location[3..-2] if location

        hashtags = tweet.split.find_all{|word| /^#.+/.match word}

        # TODO: Get the hashtags
        puts "Name: #{name}"
        puts "Twitter Handle: #{username}"
        puts "User Location: #{location}"
        puts "Hashtags: #{hashtags}"
        
        # FIXME: Songs with "by" in the name do not work. See Error #1 below
        song_metadata = tweet[/by[\w\W]+(((http\:\/\/){1}))/i]
        if song_metadata
          artist_handle = song_metadata[/(?<=^|(?<=[^a-zA-Z0-9\_\.]))@([A-Za-z0-9\_]+)/i]
          if artist_handle
            artist_handle = artist_handle[1..-1]
            @artist = get_user_real_name(artist_handle) if verify_artist(artist_handle)
          else
            location = tweet[/\([\s]*@([^\)]+)\)/i]
            if !location
              @artist = song_metadata[3..-9]
            else
              @artist = tweet[/by[\w\W]+[(@]/i]
              @artist = @artist[3..-3] if @artist
            end
          end

          the_name = @artist[/[\w\W]+[|]/i]
          @artist = the_name[0..-2] if the_name
          puts "Artist name: #{@artist}"

          @title = tweet[/\"[\s\S\d\D\w\W]+\"/i]
          if @title
            the_song = @title[/[\w\W\d\D\s\S"] +"[\w\W\d\D\s\S]+\w/i]
            @title = the_song ? the_song[3..-1] : @title[1..-2]
            puts "Song name: #{@title}\n\n\n"
          end
        end
        
        # TODO: Save artist handle
        next unless @artist && @title
        TwitterCrawl.create do |t|
          t.name = name
          t.username = username
          t.location = location
          t.date = Time.now.utc
          t.song = {title: @title, artist: @artist}
          t.tags = hashtags
        end
      end
    end
  end
end

def get_search_results(url)
  Nokogiri::HTML open(url)
rescue => e
  puts "Exception: #{e.message}. Trying again in 15s."
  sleep 15
  false
end

def verify_artist(artist)
  Twitter.user(artist).verified
  true
rescue => e
  puts "Exception: #{e.message}. Not verified."
  sleep 15
  false
end

def get_user_real_name(handle)
  Twitter.user(handle).name
rescue => e
  puts "Exception: #{e.message}. Not verified."
  sleep 15
  false
end

# FIXME: Error #1
# My soundtrack: ♫ "Babylon" by David Gray (@ La Buena Vida, Davis, CA, USA) http://sdtk.fm/16VgTj9 

# Name: Elias Mbvukuta
# Twitter Handle: mbvukutaphiri
# User Location: La Buena Vida, Davis, CA, USA
# Artist name: on" by David Gray 
# Song name: Babylon

# CONSOLE TEST
# song_metadata = tweet[/by[\w\W]+(((http\:\/\/){1}))/i]
# => "bylon\" by David Gray (@ La Buena Vida, Davis, CA, USA) http://"

# -----

# WORKS
# My soundtrack: ♫ "Pura Carroceria" by Los del Río (@ La Buena Vida, Davis, CA, USA) http://sdtk.fm/18BdJ3c 

# Name: Elias Mbvukuta
# Twitter Handle: mbvukutaphiri
# User Location: La Buena Vida, Davis, CA, USA
# Artist name: Los del Río 
# Song name: Pura Carroceria

# -----

# SHOULD BE OK
# Tweet text:
# Now playing  ♫ "Wonderful Life" by Alter Bridge | via #soundtracking app http://instagram.com/p/dGW9louvBj/ 

# Name: ☠☠☠  Chad  ☠☠☠
# Twitter Handle: 916BUCKEYE
# User Location: 
# Artist name: Alter Bridge | via #soundtracking app
# Song name: Wonderful Life

# -----

# Tweet text:
# My soundtrack: ♫ "Summer Love (feat. Jose James)" by SOIL & "PIMP" SESSIONS http://sdtk.fm/19zk7wF 

# ♫ 太陽べりぐ〜

# Name: Chihiro☆
# Twitter Handle: lovelychihiron
# User Location: 
# Artist name: SOIL & "PIMP" SESSIONS
# Song name: PIMP