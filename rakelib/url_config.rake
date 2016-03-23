file URL_CONFIG => CONFIG_DIR do
  warn 'initialize URLs...'
  File.open(File.join(CONFIG_DIR, 'search_url.yml'), 'w') do |f|
    f.puts '---'
    f.puts '- https://www.bing.com/news?q=NFL+News&FORM=NSBABR'
    f.puts '- https://www.bing.com/news?q=CFB+News&FORM=NSBABR'
    f.puts '- https://www.bing.com/news?q=MLB+News&FORM=NSBABR'
    f.puts '- https://www.bing.com/news?q=NBA+News&FORM=NSBABR'
    f.puts '- https://www.bing.com/news?q=NHL+News&FORM=NSBABR'
    f.puts '- https://www.bing.com/news?q=Soccer+News&FORM=NSBABR'
    f.puts '- https://www.bing.com/news?q=CBB+News&FORM=NSBABR'
    f.puts '- https://www.bing.com/news?q=Golf+News&FORM=NSBABR'
    f.puts '- https://www.bing.com/news?q=Tennis+News&FORM=NSBABR'
  end
end