namespace :heroku do
  namespace :config do
    task :push => :environment do
      config_opts = ENV['APP'] ? "-a #{ENV['APP']}" : ''
      config = YAML.load_file(File.join(Rails.root, 'config', 'env.yml'))
      config_str = config.map { |(k,v)| "#{k}='#{v}'" }.join(' ')
      system "heroku config:add #{config_opts} #{config_str}"
    end
  end
end
