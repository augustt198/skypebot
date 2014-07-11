# skypebot

A bot framework for Skype that allows for easy command registration.

## Usage

The bot can be started by executing `skype.rb`

```sh
$ ruby skypebot.rb [options]
```

Command options:

```
Usage: ruby skypebot.rb [options]
    -i, --id ID                      Select chat by ID
    -t, --topic TOPIC                Select chat by topic
    -m, --members                    Select a chat containing member(s)
    -s, --skip                       Begin at the most recent message
```

## Commands & Listeners
This SkypeBot framework provides a DSL for easily creating commands and listeners.

```ruby
command 'hello', help: 'Get a greeting' do |cmd|
  if cmd.has_flag? 'casual'
    cmd.reply "Hi #{cmd.user}"
  else
    cmd.reply "Greetings, #{cmd.user}."
  end
end
```

Adding listeners is also supported:
```ruby
listen match: /(skypebot)/i do |msg|
  msg.reply 'I heard my name!'
end
```
