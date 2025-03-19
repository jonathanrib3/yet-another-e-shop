module Errors; end

Rails.autoloaders.main.push_dir("#{Rails.root}/app/errors", namespace: Errors)
