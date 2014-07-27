require './command_runner'
require 'json'
require 'httparty'

include SkypeBot::Executor

if SkypeBot::CONFIG.gist_username

  def upload_gist(content, filename = 'gist.txt')
    if match = content.match(/FILENAME=([a-zA-Z0-9\\.]*)/)
      filename = match[1]
      content.gsub!(/FILENAME=([a-zA-Z0-9\\.]*)/, '')
    end
    body = {files: {filename => {content: content}}}.to_json
    headers = {'User-Agent' => SkypeBot::CONFIG.gist_username}
    post = HTTParty.post('https://api.github.com/gists', body: body, headers: headers)
    post.parsed_response['html_url']
  end

  # Override help
  command 'help', help: 'Get this gist' do |cmd|
    content = ['# Help']
    commands = SkypeBot::Executor.message_reader.commands
    commands.each_pair do |name, info|
      help = info[:help] || 'No help entry'
      content << " * `#{name}` - #{help}"
    end
    gist = upload_gist(content.join("\n\n"), 'commands.md')
    cmd.reply "Help: #{gist}"
  end

  command 'gist', help: 'Upload a gist' do |cmd|
    gist = upload_gist(cmd.content)
    cmd.reply "Here is your gist: #{gist}"
  end

  if SkypeBot::CONFIG.gist_long_messages == true
    listen do |msg|
      content = msg.content
      if content.length > 400
        gist = upload_gist(content)
        msg.reply "That message was a bit long, so I created a gist for it: #{gist}"
      end
    end
  end
end
