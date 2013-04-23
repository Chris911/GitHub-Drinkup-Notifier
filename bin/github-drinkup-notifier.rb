require 'feedzirra'

# fetching a single feed
feed = Feedzirra::Feed.fetch_and_parse("https://github.com/blog/drinkup.atom")

puts feed.title
puts feed.last_modified

puts feed.entries.first.title
puts feed.entries.first.published
puts feed.entries.first.content.sanitize