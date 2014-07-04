require 'skype'
require 'optparse'
require 'ostruct'

require './command_runner'
require './message_reader'

module SkypeBot
  CMD_DELIMITER = '$' # The command delimiter
  VERSION = '0.0.1'
  LOOP_SLEEP = 2 # Time in seconds between each message lookup loop
end


runner = SkypeBot::CommandRunner.new(ARGV)
runner.run
