apply File.expand_path('../my_rails.rb', __FILE__)

gem 'devise' # for authentication
gem 'pundit' # for authorization
run 'bundle install'
generate("devise:install")

git add: '.'
git commit: "-a -m 'Add: Devise gem'"
rake("default")
say "Added devise to new rails app."
