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
  browser.quit
end

desc 'get some Bing points'
task :bing_search do
  modes = [:pc, :mobile]
  logger = Application.logger
  keywords_source = YAML::load_file(CONFIG_DIR + 'topics.yml')
  keywords = Application.topics(keywords: keywords_source, modes: modes)
  modes.each do |mode|
    browser = Application.browser(screen_capture_dir: TMP_DIR, mode: mode, logger: logger)
    Application.show_points(browser: browser) if mode == modes.first
    Application.bing_search(browser: browser, keywords: keywords[mode])
    Application.show_points(browser: browser) if mode == modes.last
    browser.quit
  end
end

desc 'run in specific mode'
task :bing_mobile do
  mode = :mobile

  logger = Application.logger
  keywords_source = YAML::load_file(CONFIG_DIR + 'topics.yml')
  keywords = Application.topics(keywords: keywords_source, modes: modes)

  browser = Application.browser(screen_capture_dir: TMP_DIR, mode: mode, logger: logger)
  Application.show_points(browser: browser)
  Application.bing_search(browser: browser, keywords: keywords[mode])
  Application.show_points(browser: browser)
  browser.quit
end

desc 'bing search in PC mode'
task :bing_pc do
  mode = :pc

  logger = Application.logger
  keywords_source = YAML::load_file(CONFIG_DIR + 'topics.yml')
  keywords = Application.topics(keywords: keywords_source, modes: modes)

  browser = Application.browser(screen_capture_dir: TMP_DIR, mode: mode, logger: logger)
  Application.show_points(browser: browser)
  Application.bing_search(browser: browser, keywords: keywords[mode])
  Application.show_points(browser: browser)
  browser.quit
end

desc 'test browser'
task :test_browser do
  logger = Logger.new($stdout)
  browser = Browser.new(logger: logger)
  logger.debug 'browser started'
  browser.quit
  logger.debug 'browser quited'
end
