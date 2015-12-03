#!/usr/bin/env ruby
require 'logger'
require 'json'
require 'net/http'
require 'optparse'

# option parsing
options = {:config => "config.rb", :defaults => "defaults.rb"}
parser = OptionParser.new do |opts|
  opts.banner = "Usage: util.rb [options]"

  opts.on('-c', '--config <config_file>',
          "Config file (default: #{options[:config]})") do |c|
    options[:config] = c
  end

  opts.on('-d', '--defaults <defaults_file>',
          "Default file (default: #{options[:defaults]})") do |d|
    options[:defaults] = d
  end

  opts.on('-h', '--help', 'Displays help') do
    puts opts
    exit
  end
end.parse!

# load defaults, override with config
load options[:config]
load options[:defaults]
@config = @defaults.merge!(@config)

# create logger
logger = Logger.new(@config[:log_location])
logger.level = Logger.const_get(@config[:log_level])
logger.formatter = proc do |severity, datetime, progname, msg|
  "[#{datetime.strftime('%Y-%m-%d %H:%M:%S')}] #{severity}: #{msg}\n"
end

# load suspended coordinators
json = File.read(@config[:items_filename])
items = JSON.parse(json, :symbolize_names => true)
logger.debug { "Loaded items from json: #{items}" }

# do something with the items you loaded
@responses = []
items.each do |item|
  logger.info { "processing item #{item}" }
  url = @config[:api_url_base] + item[:id]
  logger.debug { "sending GET to #{url}" }
  resp = Net::HTTP.get_response(URI.parse(url))
  @responses << JSON.parse(resp.body)
end

# write responses to output file
File.open(@config[:output_filename], "w") do |outfile|
  if @config[:pretty_output]
    outfile.write(JSON.pretty_generate(@responses))
  else
    outfile.write(@responses.to_json)
  end
end
