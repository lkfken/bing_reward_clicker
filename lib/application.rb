class Application
  def self.is_production?
    stage == :production
  end

  def self.stage
    ENV['stage'].downcase.to_sym
  end

  def self.user
    name = ENV['bing_username']
    raise "please config your .env file" if name == '<username>'
    name
  end

  def self.password
    ENV['bing_password']
  end
end