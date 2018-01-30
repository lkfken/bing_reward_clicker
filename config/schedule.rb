job_type :rbenv_rake, %Q{export PATH=$HOME/.rbenv/bin:$PATH; eval "$(rbenv init -)"; cd :path && bundle exec rake :task --silent :output }

every :day, :at => '7:00am' do
  rbenv_rake 'default', :output => { :error => './log/error.log', :standard => './log/cron.log'}
end
