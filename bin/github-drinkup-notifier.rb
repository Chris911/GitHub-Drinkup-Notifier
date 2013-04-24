require 'gmail'
require 'feedzirra'

# fetching a single feed
LAST_MODIFIED_TEST = Time.new(2013, 04, 21)
EMAILS_TEST = {"Firenze" => ["Christophe.naud.dulude@gmail.com", "christophe911@hotmail.com"]}

gmail = Gmail.connect('github.drinkup.notifier','hello_dave')
feed = Feedzirra::Feed.fetch_and_parse("https://github.com/blog/drinkup.atom")

if feed.last_modified > LAST_MODIFIED_TEST
  entries = feed.entries
  entries.take_while{|entry| entry.last_modified > LAST_MODIFIED_TEST}.each do |entry|
    city = entry.title[/(.*)\s[dD]rinkup/,1] if entry.title =~ /.*\s[dD]rinkup/
    city = entry.title[/[dD]rinkup\s[iI]n\s([a-zA-Z]*)/,1] if entry.title =~ /[dD]rinkup\s[iI]n\s.*/
    next if city.nil?
    if EMAILS_TEST.has_key? city
      emails = EMAILS_TEST[city]
      emails.each do |email|
        gmail.deliver do
          to   email
          from 'GitHub Drinkup Notifier'
          subject "GitHub Drinkup Notifier : #{city}"
          body "There seems to be a GitHub drinkup if your city!\nMore at #{entry.url}"
        end
      end
    end
  end
end