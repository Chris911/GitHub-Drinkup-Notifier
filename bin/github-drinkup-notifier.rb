require 'gmail'
require 'feedjira'
require 'yaml'

require_relative '../lib/extend_string'
require_relative '../lib/githubNotifier'

last_checked_file = "#{ENV['HOME']}/.github_drinkup_notifier"
last_checked = File.exists?(last_checked_file) ?
               Time.parse(File.read(last_checked_file)) :
               Time.now() - (14 * 24 * 60 * 60) # 2 weeks ago

config = YAML::load_file(File.join(__dir__, '../config/config.yaml'))['config']

notifier = GithubNotifier.new(config, last_checked)
notifier.run

File.open(last_checked_file, 'w') { |file| file.write(Time.now()) }
