logfile = File.open(File.join(Rails.root, 'log', 'resque.log'), 'a')
logfile.sync = true
Resque.logger = ActiveSupport::Logger.new(logfile)
Resque.logger.level = Logger::INFO
Resque.redis = ENV['REDISCLOUD_URL'] || 'localhost:6379'