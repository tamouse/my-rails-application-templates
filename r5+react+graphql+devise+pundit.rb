# run with --skip-spring --skip-turbolinks --skip-bundle

gem 'redis', '~> 4.0'
gem "bcrypt", "~> 3.1.7"
gem_group :development, :test do
  gem "factory_bot_rails"
  gem "faker"
  gem "pry-rails"
  gem "pry-byebug"
  gem "pry-nav"
end

run "bundle install"

## DEVISE

gem "devise"
run "bundle install"
generate "devise:install"
application(nil, env: "development") do
  'config.action_mailer.default_url_options = { host: "localhost", port: 3000 } # Setup for devise'
end
inject_into_file 'app/views/layouts/application.html.erb', after: "<body>\n" do <<-'RUBY'
    <header class="devise-alert-header">
      <p class="notice"><%= notice %></p>
      <p class="alert"><%= alert %></p>
    </header>
RUBY
end


generate "controller home welcome"
route 'root to: "home#welcome"'
generate "devise User"
rake "db:migrate"

## PUNDIT

gem "pundit"
run "bundle install"
generate "pundit:install"

## GRAPHQL

gem "graphql"
run "bundle install"
generate "graphql:install"
run "bundle install"

## REACT

gem "webpacker"
gem "react-rails"
run "bundle install"
rake "webpacker:install"
rake "webpacker:install:react"
generate "react:install"
inject_into_file 'app/views/layouts/application.html.erb', after: "<%= javascript_include_tag 'application' %>\n" do <<-'RUBY'
    <%= javascript_pack_tag    'application' %>\n
RUBY
end

run "yarn upgrade"
run "yarn add apollo-boost react-apollo graphql"
