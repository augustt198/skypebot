require 'skype'
require 'optparse'
require 'ostruct'

require './command_runner'
require './message_reader'

module SkypeBot
  CMD_DELIMITER = '$' # The command delimiter
  VERSION = '0.0.1'
  LOOP_SLEEP = 2 # Time in seconds between each message lookup loop
  TIME_FORMAT = '%T'
end

if ARGV[0] == 'list-chats'
  puts 'Chats:'
  Skype.chats.each do |chat|
    topic = chat.topic.empty? ? '(None)' : chat.topic
    topic = topic.length > 80 ? topic.slice(0, 80) : topic
    members = (chat.members.length > 4 ? chat.members.slice(0, 4) + ['And Others'] : chat.members).join ', '
    puts '--------------------------------------------------------------------------'
    puts " * ID: #{chat.id}"
    puts " * Topic: #{topic}"
    puts " * Members: #{members}"
  end
  puts '--------------------------------------------------------------------------'
  exit
end

runner = SkypeBot::CommandRunner.new(ARGV)
runner.run
