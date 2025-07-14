module Errors; end

Rails.autoloaders.main.push_dir(Rails.root.join('app/errors').to_s, namespace: Errors)
