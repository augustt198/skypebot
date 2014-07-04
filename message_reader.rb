module SkypeBot
  class MessageReader < Thread

    attr_reader :chat
    attr_accessor :last_id # The last message ID read
    attr_reader :commands, :listeners

    # `skip` param skips over all prexisting messages
    def initialize(chat, config, skip = true)
      @chat = chat

      abort_on_exception = true
      config.command_paths.each { |x| load x }
      #config.listener_paths.each { |x| require x }

      self.last_id = chat.messages.last.id if skip
      super &self
    end

    def to_proc
      Proc.new { self.run }
    end

    def run
      loop do
        chat.messages.each do |message|
          next if message.id < last_id
          # TODO: command handling
        end
        sleep SkypeBot::LOOP_SLEEP
      end
    end

  end
end
