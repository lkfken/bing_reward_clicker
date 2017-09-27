require 'bundler'
Bundler.require
require 'logger'
require 'yaml'
require_relative 'lib/notification'

DASHBOARD_URL = 'https://account.microsoft.com/rewards/dashboard'
TOTAL_SEARCH = 30

ROOT_DIR   = Pathname.new(File.dirname(__FILE__))
CONFIG_DIR = ROOT_DIR + 'config'
LOGGER_DIR = ROOT_DIR + 'log'

directory CONFIG_DIR
directory LOGGER_DIR

def logger
  @logger ||= Logger.new(LOGGER_DIR + 'run.log', shift_age = 7, shift_size = 1048576)
end

def browser
  @browser ||= Selenium::WebDriver.for :firefox, :marionette => true
end

def stage
  @stage ||= ENV['stage'].to_sym
end

def is_production?
  stage == :production
end

def headless
  @headless ||= begin
    if defined? Headless
      headless = Headless.new
      headless.start
      headless
    end
  end
end

desc 'connect to Bing Dashboard'
task :connect => ['.env', LOGGER_DIR] do
  Dotenv.load!
  username = ENV['bing_username']
  password = ENV['bing_password']
  abort "please config your .env file" if username == '<username>'

  logger.debug 'Running...'
  logger.debug 'headless mode' if headless

  logger.debug 'Navigate to Bing Dashboard'
  browser.navigate.to DASHBOARD_URL

  # login
  logger.debug 'Login...'
  sign_in_link = { :xpath => "//div[contains(@class, 'msame_Header_name msame_TxtTrunc') and text()='Sign in']" }
  begin
    wait_for(10) { browser.find_element(sign_in_link).click }
  rescue Selenium::WebDriver::Error::TimeOutError => ex
    hostname = Socket.gethostbyname(Socket.gethostname).first
    message  = [hostname, ex.message].join("\n")
    Notification.deliver(recipient: ENV['recipient'], subject: 'bing_reward_clicker: Unable to locate sign in link', body: message, logger: logger)
    raise ex
  end

  # submit credential
  begin
    wait_for(10) { browser.find_element(:id => 'i0116').send_key(username) }
    browser.find_element(:id => 'idSIButton9').click
    wait_for(5) { browser.page_source.match(/Password/) }
    # browser.find_element(:id => 'i0118').send_key(password)
    wait_for(10) { browser.find_element(:id => 'i0118').send_key(password) }

    browser.find_element(:id => 'idSIButton9').submit

  rescue Selenium::WebDriver::Error::TimeOutError, Selenium::WebDriver::Error::NoSuchElementError => ex
    filename = File.join('tmp', "#{Time.now.strftime('%Y%m%d%H%M%S')}.html")
    File.open(filename, 'w') { |f| f.puts browser.page_source }
    message = [hostname, ex.message].join("\n")
    Notification.deliver(recipient: ENV['recipient'], subject: 'bing_reward_clicker: Unable to submit credential', body: message, logger: logger)
    logger.error 'error on submitting the credential'
    logger.error ex
    logger.error 'Abort!'
    raise ex
  end

  sleep_duration = 1
  max_try        = 5
  counter        = 0

  sleep(sleep_duration)

  begin
    wait_for(10) { browser.page_source.match(/Available points/) }
  rescue Selenium::WebDriver::Error::JavascriptError => ex
    logger.fatal ex.message
    counter += 1
    logger.fatal "Try ##{counter}: sleep(#{sleep_duration}) and try again."
    sleep(sleep_duration)
    retry if counter < max_try
  rescue Selenium::WebDriver::Error::TimeOutError => ex
    logger.fatal ex.message
    logger.fatal 'check your credential'
    browser.save_screenshot("./tmp/#{Time.now.to_s}.png")
    raise ex
  end

  logger.debug 'Logged in'
  sleep(5)
end

def bing_urls
  words  = YAML::load_file('./config/topics.yml')
  topics = words.sample(TOTAL_SEARCH) # 5 points for each search, total 150 points could earn in one day
  topics.map do |topic|
    "https://www.bing.com/news?q=\"#{topic}\"+News&FORM=NSBABR"
  end
end

desc 'search using Bing'
task :run => [:connect] do
  score_before = 0
  while score_before.zero?
    score_before = wait_for(10) { browser.find_element(:class => 'info-title').text.gsub(',', '').to_i }
    sleep(2) if score_before.zero?
  end
  logger.debug "Points before: #{score_before}"

  if is_production?
    bing_urls.each do |u|
      browser.navigate.to u
      logger.debug "Navigate to #{u}" unless is_production?
      sleep(rand(1..5))
    end
  end

  # check final points
  browser.navigate.to DASHBOARD_URL
  # wait_for(10) { browser.page_source.match(/Bing Rewards/) }
  wait_for(10) { browser.find_element(:id => 'rewards-helplinks-contact-microsoft-rewards-support') }
  score_after = wait_for(10) { browser.find_element(:class => 'info-title').text.gsub(',', '').to_i }
  logger.debug "Points after: #{score_after}"
  logger.debug "Earned: #{score_after - score_before}"

  browser.close
  logger.debug 'Close browser'

  if headless
    headless.destroy
    logger.debug 'Destroy headless'
  end

end

def wait_for(seconds)
  Selenium::WebDriver::Wait.new(timeout: seconds).until { yield }
end
