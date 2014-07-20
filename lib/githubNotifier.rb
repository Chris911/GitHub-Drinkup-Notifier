class GithubNotifier

  def initialize(config, last_checked)
    @config = config
    @last_checked = last_checked
  end

  def gmail
    @gmail ||= Gmail.connect(@config['notifier']['email'],@config['notifier']['password'])
    unless @gmail.logged_in?
      puts "Wrong Email/Password Combination"
      exit(1)
    end
    @gmail
  end

  def run
    feed = Feedjira::Feed.fetch_and_parse("https://github.com/blog/drinkup.atom")

    if feed.last_modified > @last_checked
      feed.entries.take_while{ |entry| entry.last_modified > @last_checked }.each do |entry|
        # String transliteration (Removed accents)
        title = entry.title.removeaccents.downcase
        
        # Match city in blog entry
        city = title[/([a-zA-Z\s]*)\s[dD]rinkup/,1]          if title =~ /.*\s[dD]rinkup/
        city = title[/[dD]rinkup\s[iI]n\s([a-zA-Z\s]*).*/,1] if title =~ /[dD]rinkup\s[iI]n\s.*/
        city = title[/([a-zA-Z\s]*)\s[mM]eetup/,1]           if title =~ /.*\s[mM]eetup/
        city = title[/[mM]eetup\s[iI]n\s([a-zA-Z\s]*).*/,1]  if title =~ /[mM]eetup\s[iI]n\s.*/
        next if city.nil?
        alerts = @config['alerts'].find_all{ |alert| alert['cities'].map(&:downcase).include?(city.downcase.strip!) }

        unless alerts.empty?
          emails = alerts.collect{ |alert| alert['email'] }

          gmail.deliver do
            to      @config['notifier']['email']
            bcc     emails.join(", ")
            from    'GitHub Drinkup Notifier'
            subject "GitHub Drinkup Notifier : #{city.capitalize}"
            body    "There seems to be a GitHub drinkup if your city!\n\nMore at #{entry.url}"
          end
        end
      end
    end
  end

end
