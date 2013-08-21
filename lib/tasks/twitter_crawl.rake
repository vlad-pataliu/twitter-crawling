require 'nokogiri'
require 'open-uri'

# TODO: Update task so that it will run the query against any argument
desc "Crawl Twitter"
namespace :twitter do
  task :crawler => :environment do
    q ||= 'soundtracking'
    url = "https://twitter.com/search/realtime?q=#{q}&src=typd"
    previousTweet, @artist, @title, @artist_twitter = ''

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

        hashtags = tweet.split.find_all{|word| /^#.+/.match word[1..-1]}

        puts "Name: #{name}"
        puts "Twitter Handle: #{username}"
        puts "User Location: #{location}"
        puts "Hashtags: #{hashtags}"
        
        song_metadata = tweet[/ by[\w\W]+(((http\:\/\/){1}))/i]
        song_metadata = song_metadata[1..song_metadata.length] if !song_metadata.nil?
        if song_metadata
          artist_handle = song_metadata[/(?<=^|(?<=[^a-zA-Z0-9\_\.]))@([A-Za-z0-9\_]+)/i]
          if artist_handle
            @artist_twitter = artist_handle
            artist_handle_without_symbol = artist_handle[1..-1]
            @artist = get_user_real_name(artist_handle_without_symbol) if verify_artist(artist_handle_without_symbol)
          else
            location = tweet[/\([\s]*@([^\)]+)\)/i]
            if !location
              @artist = song_metadata[3..-9]
            else
              @artist = song_metadata[/by[\w\W]+[(@]/i]
              @artist = @artist[3..-3] if @artist
            end
          end

          the_name = @artist[/[\w\W]+[|]/i] if @artist
          @artist = the_name[0..-3] if the_name
          puts "Artist name: #{@artist}"

          @title = tweet[/\"[\s\S\d\D\w\W]+\" by/i]
          if @title
            the_song = @title[/[\w\W\d\D\s\S"] +"[\w\W\d\D\s\S]+\w/i]
            @title = the_song ? the_song[3..-1] : @title[1..-5]
            title_verification = @title[/" by/i]
            @title = @title[0..-5] if title_verification
            puts "Song name: #{@title}\n\n\n"
          end
        end
        
        next unless @artist && @title
        TwitterCrawl.create do |t|
          t.text = tweet
          t.name = name
          t.username = username
          t.location = location
          t.date = Time.now.utc
          t.song = {title: @title, artist: {name: @artist, twitter: @artist_twitter}}
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
  true if Twitter.user(artist).verified
rescue => e
  puts "Exception: #{e.message}. Not verified."
  sleep 15
  false
end

def get_user_real_name(handle)
  Twitter.user(handle).name
rescue => e
  puts "Exception: #{e.message}. Could not get user's real name."
  sleep 15
  false
end