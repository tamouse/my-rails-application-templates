# Run with rails options: --skip-bundle --skip-test-unit --skip-spring --skip-turbolinks -m /Users/tamara/.railsrc.d/example_app.rb
@app_name = File.basename(Dir.pwd, '.*')
remove_file "Gemfile"
create_file "Gemfile", ''
add_source "https://rubygems.org"
append_to_file "Gemfile", "ruby '2.2.2'"
gem "rails", "4.2.2"
gem "sqlite3"
gem "sass-rails", "~> 5.0"
gem "uglifier", ">= 1.3.0"
gem "coffee-rails", "~> 4.1.0"
gem "jquery-rails"
gem "jbuilder", "~> 2.0"
gem "bcrypt", "~> 3.1.7"
gem "unicorn"
gem "capistrano-rails", group: :development

gem "haml-rails"
gem "bootstrap-sass"
gem "fontawesome-rails", github: "tamouse/fontawesome-rails"
gem "twitter_bootstrap_form_for", github: "tamouse/twitter_bootstrap_form_for"

gem_group :development, :test do
  gem 'pry-rails'
  gem 'pry-byebug'
  gem 'awesome_print'
  gem 'rspec-rails'
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'quiet_assets'
  gem 'html2haml'
end

remove_file "app/assets/stylesheets/application.css"
remove_file "app/views/layouts/application.html.erb"
source_paths << File.dirname(__FILE__)
directory "templates/lib", "lib"
directory "templates/app", "app"
directory "templates/scripts", "scripts"
chmod "scripts/setup.sh", 0755

append_to_file("app/assets/javascripts/application.js") do
  %q{//= require bootstrap-sprockets
}
end

remove_file "README.rdoc"
template "templates/README.md", "README.md"

say "New rails application #{@app_name} assembled!", :green
