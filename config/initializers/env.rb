env_file = File.join(Rails.root, 'config', 'env.yml')
if File.exists? env_file
  env_data = YAML.load_file(env_file)
  env_data.each_pair { |k,v| ENV[k] = v }
end
