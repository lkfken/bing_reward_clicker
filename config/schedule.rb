job_type :rbenv_rake, %Q{export PATH=$HOME/.rbenv/bin:$PATH; eval "$(rbenv init -)"; cd :path && bundle exec rake :task --silent :output }

every :day, :at => '8:15am' do
  rbenv_rake 'bing_search', :output => { :error => './log/error.log', :standard => './log/cron.log'}
end
