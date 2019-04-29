require 'bundler'
Bundler.require
Dotenv.load!
require 'logger'
require 'yaml'
require 'pp'

require_relative 'lib/application'
require_relative 'lib/bing'
require_relative 'lib/browser'
require_relative 'lib/notification'

ROOT_DIR = Pathname.new(File.dirname(__FILE__))
CONFIG_DIR = ROOT_DIR + 'config'
LOGGER_DIR = ROOT_DIR + 'log'
TMP_DIR = ROOT_DIR + 'tmp'

directory CONFIG_DIR
directory LOGGER_DIR
directory TMP_DIR

def logger
  @logger ||= begin
    log_dev = Application.is_production? ? (LOGGER_DIR + 'run.log') : (LOGGER_DIR + "#{stage.to_s}.log")
    lgr = Logger.new(log_dev) #Selenium::WebDriver.logger
    lgr.level = Application.is_production? ? :info : :debug
    lgr
  end
end

desc 'get some bing points'
task :get_bing_points do
  browser = Browser.new(mode: :mobile, logger: logger)
  browser.start_headless if defined? Headless

  if Application.is_production?
    login = Bing::Login.new(browser: browser, username: Application.user, password: Application.password, logger: logger)
    login.run
    points = Bing::Points.new(browser: browser)
    logger.info "Available: #{points.available_points}"
    logger.info points.points_detail.inspect
  end

  total = browser.pc_mode? ? 10 : 10
  topics = Bing::Topics.new(total: total, keywords: YAML::load_file('./config/topics.yml'))
  search = Bing::Search.new
  topics.each do |topic|
    search.topic = topic
    browser.jump_to search.url
    sleep(rand(1..5)) if Application.is_production?
  end

  if login && points
    logger.info "Available: #{points.available_points}"
    logger.info points.points_detail.inspect
  end

  browser.quit
end
