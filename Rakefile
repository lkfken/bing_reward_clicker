require 'bundler'
Bundler.require
require 'logger'
require 'yaml'
require 'pp'
require_relative 'lib/notification'

DASHBOARD_URL = 'https://account.microsoft.com/rewards/dashboard'
BING_URL = 'http://www.bing.com'
TOTAL_SEARCH = 12

ROOT_DIR = Pathname.new(File.dirname(__FILE__))
CONFIG_DIR = ROOT_DIR + 'config'
LOGGER_DIR = ROOT_DIR + 'log'
TMP_DIR = ROOT_DIR + 'tmp'

directory CONFIG_DIR
directory LOGGER_DIR
directory TMP_DIR

def logger
  @logger ||= begin
    lgr = Selenium::WebDriver.logger
    lgr.level = is_production? ? :error : :debug
    log_dev = is_production? ? File.join(LOGGER_DIR, 'run.log') : $stderr
    lgr.output = log_dev
    lgr
  end
end

def browser
  @browser ||= begin
    unless is_production?
      driver = Selenium::WebDriver.for :firefox, :marionette => true
      original_agent = driver.execute_script("return navigator.userAgent")
      logger.debug original_agent
    end


    profile = Selenium::WebDriver::Firefox::Profile.new
    profile['general.useragent.override'] = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:66.0) Gecko/20100101 Firefox/66.0'

    options = Selenium::WebDriver::Firefox::Options.new
    options.profile = profile

    Selenium::WebDriver.for :firefox, :marionette => true, :options => options
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
  browser.navigate.to DASHBOARD_URL

  #maximize browser
  browser.manage.window.maximize

  # login
  logger.info 'Login...'
  xpath = "//div[contains(@class, 'mectrl_profilepic mectrl_glyph glyph_signIn_circle')]"
  # xpath = "//div[contains(@class, 'mectrl_signin mectrl_truncate') and text()='Sign in']"
  sign_in_link = {:xpath => xpath}

  begin
    browser.find_element(sign_in_link).click
  rescue Selenium::WebDriver::Error::NoSuchElementError => ex
    hostname = Socket.gethostbyname(Socket.gethostname).first
    messages = [" Host : #{hostname}", ex.message]
    if is_production?
      Notification.deliver(recipient: ENV['recipient'], subject: 'bing_reward_clicker: Unable to locate sign in link', body: messages.join("\n"), logger: logger)
    else
      logger.error messages.join(' ')
    end
    raise ex.class, messages.join(' ')
  end

  logger.info 'Submit username...'
  browser.find_element(:id => 'i0116').send_key(username)
  browser.find_element(:id => 'idSIButton9').click

  logger.info 'Submit password...'
  browser.page_source.match(/Password/)
  browser.find_element(:id => 'i0118').send_key(password)
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
