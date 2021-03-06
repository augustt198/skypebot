# Core commands
require './command_runner'

include SkypeBot::Executor

command 'help', help: 'Show this message' do |cmd|
  commands = SkypeBot::Executor.message_reader.commands
  cmd.reply 'Commands:'
  commands.each_pair do |name, info|
    cmd.reply " * #{name} - " + (info[:help] ? info[:help] : "No help entry")
  end
end

command 'version', help: 'Get the current bot version' do |cmd|
  cmd.reply "The current SkypeBot version is #{SkypeBot::VERSION}"
end

command 'is', help: 'Is it?' do |cmd|
  msg = ['Yes', 'No', 'Definitely', 'Not a chance', 'Absolutely', 'I doubt it',
         'Obviously', 'Not at all'].sample
  cmd.reply msg
end
