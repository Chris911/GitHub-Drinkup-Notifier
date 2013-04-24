require 'gmail'
require 'feedzirra'
require 'yaml'
require '../lib/extend_string'

LAST_MODIFIED_TEST = Time.new(2013, 04, 10)
EMAILS_TEST = {"firenze" => ["Christophe.naud.dulude@gmail.com", "christophe911@hotmail.com"],
"london" => ["christophe911@hotmail.com"]}

config = YAML.load_file("../config/config.yaml")
gmail = Gmail.connect(config['config']['email'],config['config']['password'])
unless gmail.logged_in?
  puts "Wrong Email/Password Combination"
  exit(1)
end
feed = Feedzirra::Feed.fetch_and_parse("https://github.com/blog/drinkup.atom")

if feed.last_modified > LAST_MODIFIED_TEST
    feed.entries.take_while{|entry| entry.last_modified > LAST_MODIFIED_TEST}.each do |entry|
    # String transliteration (Removed accents)
    title = entry.title.removeaccents.downcase
    # Match city in blog entry
    city = title[/([a-zA-Z\s]*)\s[dD]rinkup/,1]          if title =~ /.*\s[dD]rinkup/
    city = title[/[dD]rinkup\s[iI]n\s([a-zA-Z\s]*).*/,1] if title =~ /[dD]rinkup\s[iI]n\s.*/
    next if city.nil?
    if EMAILS_TEST.has_key? city
      emails = EMAILS_TEST[city]
      gmail.deliver do
        to      config['config']['email']
        bcc     emails.join(", ")
        from    'GitHub Drinkup Notifier'
        subject "GitHub Drinkup Notifier : #{city.capitalize}"
        body    "There seems to be a GitHub drinkup if your city!\nMore at #{entry.url}"
      end
    end
  end
end