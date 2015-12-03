require 'logger'
require 'json'
require 'net/http'

# load defaults, override with config
load "config.rb"
load "defaults.rb"
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
