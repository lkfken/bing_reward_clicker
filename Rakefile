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
  [:pc, :mobile].each {|mode| Application.run(mode: mode)}
end

desc 'test browser'
task :test_browser do
  logger = Logger.new($stdout)
  options = Selenium::WebDriver::Firefox::Options.new
  options.headless! if defined? Headless
  browser = Browser.new(logger: logger)
  logger.debug 'browser started'
  browser.quit
  logger.debug 'browser quited'
end