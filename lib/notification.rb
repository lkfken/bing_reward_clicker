require 'mail'
require 'logger'
class Notification
  def self.deliver(recipient:, sender: 'do-not-reply@bing_reward_clicker.app', subject:, body:, logger: Logger.new($stderr))
    options = { :address              => "smtp.gmail.com",
                :port                 => 587,
                :domain               => 'bing_reward_clicker.app',
                :user_name            => ENV['gmail_username'],
                :password             => ENV['gmail_password'],
                :authentication       => 'plain',
                :enable_starttls_auto => true }

    Mail.defaults do
      delivery_method :smtp, options
    end
    Mail.deliver do
      to recipient
      from sender
      subject subject
      body body
    end
    logger.debug "Notification sent to #{recipient} about #{subject}"
  end
end