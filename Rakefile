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

task :default => [:show_points]

desc 'show Bing points'
task :show_points do
  browser = Application.browser(screen_capture_dir: TMP_DIR, mode: :mobile, logger: Logger.new($stdout))
  Application.show_points(browser: browser)
  # browser.quit
end

desc 'get some Bing points'
task :bing_search do
  logger = Application.logger

  keywords = YAML::load_file(CONFIG_DIR + 'topics.yml')
  modes = [:pc, :mobile]
  keywords_pool = keywords.shuffle.each_slice(keywords.size / modes.size)
  topics = modes.inject(Hash.new) do |h, mode|
    some_topics = keywords_pool.next
    h[mode] = some_topics
    h
  end

  modes.each do |mode|
    browser = Application.browser(screen_capture_dir: TMP_DIR, mode: mode, logger: logger)
    Application.show_points(browser: browser) if mode == modes.first
    Application.bing_search(browser: browser, keywords: topics[mode])
    Application.show_points(browser: browser) if mode == modes.last
    browser.quit
  end
end

desc 'test browser'
task :test_browser do
  logger = Logger.new($stdout)
  browser = Browser.new(logger: logger)
  logger.debug 'browser started'
  browser.quit
  logger.debug 'browser quited'
end
