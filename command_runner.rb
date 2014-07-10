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

      @config.initializers.each { |f| load f }
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
        opts.banner = 'Usage: ruby skypebot.rb [options]'

        opts.on '-i', '--id ID', 'Select chat by ID' do |id|
          options[:id] = id
        end
        opts.on '-t', '--topic TOPIC', 'Select chat by topic' do |topic|
          options[:topic] = topic
        end
        opts.on '-m', '--members', Array, 'Select a chat containing member(s)' do |members|
          options[:members] = true
        end
        opts.on '-s', '--skip', 'Begin at the most recent message' do
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

  class Message
    attr_accessor :response
    attr_reader :msg, :chat, :content, :user

    def initialize(msg, chat)
      @msg, @chat= msg, chat
      @user = msg.user
      @content = msg.body
      @response = []
    end

    alias_method :body, :content

    def reply(msg)
      @response << msg
    end

    def user
      msg.user
    end

    def id
      chat.id
    end

    def to_s
      content
    end

    alias_method :respond, :reply
  end

  class Command < Message
    attr_reader :args, :flags, :command

    def initialize(command, args, msg, chat)
      @command, @args = command, args
      @flags = []
      super msg, chat
    end

    def joined
      args.join ' '
    end

    alias_method :body, :joined
    alias_method :content, :joined

    def arg(n)
      args[n]
    end

    def has_flag?(flag)
      # Double-dash is assumed if flag is longer than
      # one character
      flag = (flag.length > 1 ? '--' : '-') + flag
      return true if @flags.include? flag
      OptionParser.new do |opts|
        opts.on flag do
          @flags << flag
          return true
        end
      end.parse! @args
      false
    end
  end
end
