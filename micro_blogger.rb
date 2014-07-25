require 'jumpstart_auth'
require 'bitly'
require 'klout'

class MicroBlogger
  attr_reader :client

  def initialize
    puts "Initializing..."
    Klout.api_key = 'xu9ztgnacmjx3bu82warbr3h'
    @client = JumpstartAuth.twitter
  end

  def tweet(message)
    if message.length <= 140
      @client.update(message)
    else
      puts "Message length over 140 characters"
    end
  end

  def shorten(original_url)
    bitly = Bitly.new('hungryacademy', 'R_430e9f62250186d2612cca76eee2dbc6')

    puts "Shortening this URL: #{original_url}"
    return bitly.shorten(original_url).short_url
  end

  def dm(target, message)
    puts "Trying to send #{target} this direct message"
    puts message

    screen_names = @client.followers.collect { |follower| follower.screen_name }
    message = "d @#{target} #{message}"

    if screen_names.include?(target)
      tweet(message)
    else
      puts "Error: Cannot direct message, @#{target} is not following you."
    end
  end

  def followers_list
    screen_names = []
    @client.followers.each do |follower|
      screen_names << follower["screen_name"]
    end
    screen_names
  end

  def spam_my_followers(message)
    followers_list.each do |follower|
      dm(follower, message)
    end
  end

  def klout_score
    friends = @client.friends.collect{|friend| friend.screen_name}

    friends.each do |friend|
      puts " @" + friend
      identity = Klout::Identity.find_by_screen_name(friend)
      user = Klout::User.new(identity.id)
      puts user.score.score
      puts ""
    end

  end

  def everyones_last_tweet
    friends = @client.friends.sort_by{ |friend| friend.name}
    friends.each do |friend|
      timestamp = friend.status.created_at
      puts friend.name + " @" + friend.screen_name + " Said This On: " + timestamp.strftime("%A, %b %d")
      puts friend.status.text
      puts ""
    end
  end

  def run
    puts "Welcome to the JSL Twitter Client!"
    command = ""
    while command != "q"
      printf "enter command: "
      input = gets.chomp
      parts = input.split(" ")
      command = parts[0]
      case command
        when 'q' then puts "Goodbye!"
        when 't' then tweet(parts[1..-1].join(" "))
        when 'dm' then dm(parts[1], parts[2..-1].join(" "))
        when 'spam' then spam_my_followers(parts[1..-1].join(" "))
        when 'elt' then everyones_last_tweet
        when 's' then puts shorten(parts[1..-1].join(" "))
        when 'turl' then tweet(parts[1..-2].join(" ") + " " + shorten(parts[-1]))
        when 'ks' then klout_score
        else puts "Sorry, I don't know how to #{command}"
      end
    end
  end

end

blogger = MicroBlogger.new
blogger.run
