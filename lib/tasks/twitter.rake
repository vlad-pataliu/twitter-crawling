# Twitter gem documentation here: http://rdoc.info/gems/twitter

namespace :crawler do
  task :twitter => :environment do
    tweets = Twitter.search("soundtracking by -rt", { lang: 'en', count: 100 } )
    tweets.statuses.map do |tweet|
      puts "#{tweet.text}\n#{tweet.user.name}\n\n"
    end

    user = Twitter.user("KeithUrban")
    p user.name
  end
end

