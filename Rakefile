require 'bundler'
Bundler.require
require 'logger'
require 'yaml'

DASHBOARD_URL = 'https://www.bing.com/rewards/dashboard'

ROOT_DIR          = Pathname.new(File.dirname(__FILE__))
CONFIG_DIR        = ROOT_DIR + 'config'
LOGGER_DIR        = ROOT_DIR + 'log'
URL_CONFIG        = CONFIG_DIR + 'search_url.yml'
SEARCH_LOOP_TOTAL = 4

directory CONFIG_DIR
directory LOGGER_DIR

desc 'execute script'
task :run => ['.env', URL_CONFIG, LOGGER_DIR] do
  logger = Logger.new(LOGGER_DIR + 'run.log', shift_age = 7, shift_size = 1048576)
  Dotenv.load!
  username = ENV['bing_username']
  password = ENV['bing_password']
  abort "please config your .env file" if username == '<username>'

  logger.debug 'Running...'
  if defined? Headless
    headless = Headless.new
    headless.start
    logger.debug 'headless mode'
  end

  browser = Selenium::WebDriver.for :firefox, :marionette => true
  logger.debug 'Navigate to Bing Dashboard'
  browser.navigate.to DASHBOARD_URL

  # login
  logger.debug 'Login...'
  wait_for(10) { browser.find_element(:xpath => "//a[@h='ID=rewards,5088.1']").click }
  wait_for(10) { browser.find_element(:id => 'i0116').send_key(username) }
  browser.find_element(:id => 'i0118').send_key(password)
  browser.find_element(:id => 'idSIButton9').click

  sleep_duration = 1
  max_try        = 5
  counter        = 0

  sleep(sleep_duration)

  begin
    wait_for(10) { browser.page_source.match(/Bing Rewards/) }
  rescue Selenium::WebDriver::Error::JavascriptError => ex
    logger.fatal ex.message
    counter += 1
    logger.fatal "Try ##{counter}: sleep(#{sleep_duration}) and try again."
    sleep(sleep_duration)
    retry if counter < max_try
  rescue Selenium::WebDriver::Error::TimeOutError => ex
    logger.fatal ex.message
    logger.fatal 'check your credential'
    raise ex
  end

  logger.debug 'Logged in'
  score_before = wait_for(10) { browser.find_element(:id => 'id_rc').text.to_i }
  logger.debug "Points before: #{score_before}"

  url = YAML::load_file(File.join('config', 'search_url.yml'))
  SEARCH_LOOP_TOTAL.times.each do
    url.each do |u|
      browser.navigate.to u
      logger.debug "Navigate to #{u}"
      sleep(1)
    end
  end

  # check final points
  browser.navigate.to DASHBOARD_URL
  wait_for(10) { browser.page_source.match(/Bing Rewards/) }
  score_after = wait_for(10) { browser.find_element(:id => 'id_rc').text.to_i }
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
