require 'bundler'
Bundler.require
Dotenv.load!

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

task :default => [:get_bing_points]

desc 'get some bing points'
task :get_bing_points do
  [:pc, :mobile].each {|mode| Application.run(mode: mode, logger: logger)}
end

desc 'test browser'
task :test_browser do
  logger = Logger.new($stdout)
  browser = Browser.new(logger: logger)
  logger.debug 'browser started'
  browser.quit
  logger.debug 'browser quited'
end
