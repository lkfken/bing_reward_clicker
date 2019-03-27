require 'bundler'
Bundler.require
require 'logger'
require 'yaml'
require 'pp'
require_relative 'lib/notification'

DASHBOARD_URL = 'https://account.microsoft.com/rewards/dashboard'
BING_URL = 'http://www.bing.com'
TOTAL_SEARCH = 32
MOBILE_AGENT = 'Mozilla/5.0 (Windows Phone 10.0; Android 4.2.1; WebView/3.0) ' + 'AppleWebKit/537.36 (KHTML, like Gecko) coc_coc_browser/64.118.222 ' + 'Chrome/52.0.2743.116 Mobile Safari/537.36 Edge/15.15063'
PC_AGENT =  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) ' + 'AppleWebKit/537.36 (KHTML, like Gecko) ' + 'Chrome/64.0.3282.140 Safari/537.36 Edge/17.17134'
ROOT_DIR = Pathname.new(File.dirname(__FILE__))
CONFIG_DIR = ROOT_DIR + 'config'
LOGGER_DIR = ROOT_DIR + 'log'
TMP_DIR = ROOT_DIR + 'tmp'

directory CONFIG_DIR
directory LOGGER_DIR
directory TMP_DIR

def logger
  @logger ||= begin
    log_dev = is_production? ? (LOGGER_DIR + 'run.log') : (LOGGER_DIR + "#{stage.to_s}.log")
    lgr = Logger.new(log_dev) #Selenium::WebDriver.logger
    lgr.level = is_production? ? :info : :debug
    lgr
  end
end

def browser
  @browser ||= begin
    unless is_production?
      driver = Selenium::WebDriver.for :firefox, :marionette => true
      original_agent = driver.execute_script("return navigator.userAgent")
      logger.debug "Original Agent: #{original_agent}"
    end

    profile = Selenium::WebDriver::Firefox::Profile.new
    profile['general.useragent.override'] = PC_AGENT
    options = Selenium::WebDriver::Firefox::Options.new
    options.profile = profile

    driver = Selenium::WebDriver.for :firefox, :marionette => true, :options => options

    agent = driver.execute_script("return navigator.userAgent")
    logger.debug "Agent now: #{agent}"
    driver
  end
end

def stage
  @stage ||= ENV['stage'].downcase.to_sym
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
task :connect => ['.env', LOGGER_DIR, TMP_DIR] do
  Dotenv.load!
  username = ENV['bing_username']
  password = ENV['bing_password']
  abort "please config your .env file" if username == '<username>'

  logger.info 'Running...'
  logger.info 'headless mode' if headless

  logger.info 'Navigate to Bing Dashboard'
  browser.navigate.to 'https://login.live.com' #DASHBOARD_URL

  #maximize browser
  browser.manage.window.maximize

  # login
  logger.info 'Login...'
  logger.info 'Submit username...'
  browser.find_element(:id => 'i0116').send_key(username)
  browser.find_element(:id => 'idSIButton9').click

  logger.info 'Submit password...'
  browser.page_source.match(/Password/)
  wait_for(10) {browser.find_element(:id => 'idSIButton9')}
  browser.find_element(:id => 'idSIButton9').click
  browser.find_element(:name => 'passwd').clear
  browser.find_element(:name => 'passwd').send_key(password)
  sleep(3)
  # sleep(10) unless is_production?
  # browser.save_screenshot(File.join(TMP_DIR, "pw_#{Time.now.strftime('%Y%m%d%H%M%S')}.png")) unless is_production?
  # File.open(TMP_DIR + "pw_#{Time.now.strftime('%Y%m%d%H%M%S')}.html", 'w') {|f| f.puts browser.page_source} unless is_production?
  browser.find_element(:id => 'idSIButton9').click

  sleep_duration = 1
  max_try = 5
  counter = 0

  browser.navigate.to BING_URL
  sleep(sleep_duration)

  begin
    wait_for(10) {browser.find_element(:id => 'id_n')}
  rescue Selenium::WebDriver::Error::JavascriptError => ex
    logger.fatal ex.message
    counter += 1
    logger.fatal "Try ##{counter}: sleep(#{sleep_duration}) and try again."
    sleep(sleep_duration)
    retry if counter < max_try
  rescue Selenium::WebDriver::Error::TimeOutError => ex
    logger.fatal ex.message
    logger.fatal 'check your credential'
    browser.save_screenshot(File.join(TMP_DIR, "#{Time.now.to_s}.png"))
    raise ex
  end

  user = browser.find_element(:id => 'id_n').text.strip
  if user.empty?
    logger.error "No user found!"
    browser.quit
    abort
  end
  logger.info "Logged in as #{user}"
end

def bing_urls
  words = YAML::load_file('./config/topics.yml')
  topics = words.sample(TOTAL_SEARCH) # 5 points for each search, total 150 points could earn in one day
  topics.map do |topic|
    "https://www.bing.com/news?q=\"#{topic}\"+News&FORM=NSBABR"
  end
end

desc 'search using Bing'
task :run => [:connect] do
  browser.navigate.to BING_URL
  score_before = 0
  while score_before.zero?
    score_before = wait_for(10) {bing_score}
    sleep(2) if score_before.zero?
  end
  logger.info "Points before: #{score_before}"

  if is_production?
    bing_urls.each do |u|
      browser.navigate.to u if is_production?
      logger.debug "Navigate to #{u}"
      sleep(rand(1..5)) if is_production?
    end
  end

  # check final points
  browser.navigate.to BING_URL
  wait_for(10) {browser.find_element(:class => 'hp_sw_logo')}
  score_after = 0
  while score_after.zero?
    score_after = wait_for(10) {bing_score}
    sleep(2) if score_after.zero?
  end

  logger.info "Points after: #{score_after}"
  logger.info "Earned: #{score_after - score_before}"

  browser.close if is_production?
  logger.info 'Close browser'

  if headless
    headless.destroy
    logger.info 'Destroy headless'
  end

end

def bing_score
  browser.find_element(:id => 'id_rc').text.gsub(',', '').to_i
end

def wait_for(seconds)
  Selenium::WebDriver::Wait.new(timeout: seconds).until {yield}
end
