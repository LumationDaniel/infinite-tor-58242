bootstrap_kaminari_gem = Gem.loaded_specs['bootstrap-kaminari-views']
ActionController::Base.view_paths << File.join(bootstrap_kaminari_gem.full_gem_path, 'app', 'views')
