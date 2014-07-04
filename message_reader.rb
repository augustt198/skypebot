module SkypeBot
  class MessageReader < Thread

    attr_reader :chat
    attr_accessor :last_id # The last message ID read
    attr_reader :commands, :listeners

    # `skip` param skips over all prexisting messages
    def initialize(chat, config, skip = true)
      @chat = chat
      @listeners = []
      @commands = {}

      
      config.command_paths.each { |x| load x }
      puts "#{config.command_paths.length} command files loaded"
      config.listener_paths.each { |x| load x }
      puts "#{config.listener_paths.length} listener files loaded"

      if skip
        @last_id = chat.messages.last.id
        puts "Skipping to last message (ID #{last_id})"
      else
        @last_id = 0
      end
      @lol = 'LOL'

      super &self
      self.abort_on_exception = true
    end

    def to_proc
      Proc.new { self.run }
    end

    def run
      loop do
        chat.messages.each do |message|
          next unless @last_id < message.id
          @last_id = message.id
          received_at = Time.now.strftime(SkypeBot::TIME_FORMAT)
          sent_at = message.time.strftime(SkypeBot::TIME_FORMAT)
          puts "[#{received_at}] message by #{message.user} (sent at #{sent_at})"
          handle_message(message, chat)
          # TODO: command handling
        end
        sleep SkypeBot::LOOP_SLEEP
      end
    end

    def handle_message(msg, chat)
      content = msg.body
      args = content.split ' '
      if args[0] and args[0].start_with?(SkypeBot::CMD_DELIMITER)
        command_name = args.shift
        command_name.slice!(1, command_name.length - 1)
        command = find_command(command_name)
        chat.post 'Unknown command' unless command
        
        to_read = SkypeBot::Command.new(command_name, args, msg, chat)

        command[:block].call(to_read)
      else
        to_read = SkypeBot::Message.new(msg, chat)

      end

      @listeners.each do |listener|
        if listener[:match]
          next unless (content =~ listener[:match]) == nil
        end
        listener[:block].call(to_read)
      end

    end

    def find_command(cmd)
      @commands.each_pair do |name, info|
        if name == cmd or info[:aliases].include?(name)
          return info
        end
      end
      nil
    end

    def on_message(options = {}, &block)
      @listeners << options.merge(block: block)
    end

    alias_method :listen, :on_message

    def command(name, options = {}, &block)
      @commands[name] = options.merge(block: block)
    end
  end
end
