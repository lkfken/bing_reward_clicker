file '.env' do
  File.open('.env', 'w') do |f|
    f.puts 'bing_username=<username>'
    f.puts 'bing_password=<password>'
  end
  warn 'Open .env file and enter the following information:'
  warn 'bing_username=<username>'
  warn 'bing_password=<password>'
  abort
end