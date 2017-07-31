file '.env' do
  lines = %w[
    bing_username=<username>
    bing_password=<password>
    recipient=<recipient>
    gmail_username=<gmail_account>
    gmail_password=<gmail_password>
  ]
  File.open('.env', 'w') do |f|
    lines.each { |line| f.puts line }
  end
  warn 'Open .env file and enter the following information:'
  warn lines.join("\n")
  abort
end