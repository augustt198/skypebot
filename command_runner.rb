require 'optparse'

module SkypeBot
  class CommandRunner

    attr_reader :args, :chat, :message_reader, :config

    def initialize(args)
      @args = args
      @config = OpenStruct.new

      @config.initializers = Dir['initializers/*.rb']
      @config.command_paths = Dir['commands/*.rb']
      @config.listener_paths = Dir['listeners/*.rb']

      @config.initializers.each { |f| require f }
    end

    def run
      options = parse_args(args)
      skip = options.delete :skip
      fail 'No option selected' if options.empty?
      fail 'Too many options selected' if options.length > 1

      @chat = find_chat options, Skype.chats
      fail 'Unable to find chat' unless @chat

      puts 'Using Chat:'
      puts " * ID: #{@chat.id}"
      topic = @chat.topic.length > 80 ? @chat.topic[0, 80] + '...' : topic
      puts " * Topic: #{topic}"
      members = @chat.members
      members = (members.length > 4 ? members.slice(0, 3) : members).join(', ')
      puts " * Members: #{members}"

      @message_reader = MessageReader.new(chat, config, skip)

      hang
    end

    def parse_args(args)
      options = {skip: false}
      OptionParser.new do |opts|
        opts.banner = 'Usage: skypebot.rb [options]'

        opts.on '-i', '--id ID', 'Select chat by ID' do |id|
          options[:id] = id
        end
        opts.on '-t', '--topic TOPIC', 'Select chat by topic' do |topic|
          options[:topic] = topic
        end
        opts.on '-m', '--members', Array, 'Select a chat containing member(s)' do |members|
          options[:members] = true
        end
        opts.on '-s', '--skip', 'Read all messages from the beginning' do
          options[:skip] = true
        end
      end.parse!
      options
    end

    def find_chat(options, chats)
      @chat = nil
      if options[:id]
        @chat = chats.find { |c| c.id.to_s == options[:id] }
        fail "Could not find chat with ID: #{options[:id]}" unless @chat
      elsif options[:topic]
        @chat = chats.find { |c| c.topic == options[:topic] }
        fail "Could not find chat with topic: #{options[:topic]}" unless @chat
      elsif options[:members]
        members = ARGV
        @chat = chats.find { |c| (c.members - members).length <= c.members.length - members.length }
        fail "Could not find chat with members: #{members}" unless @chat
      end
      @chat
    end

    def hang
      sleep 10 while true
    end

  end
end
