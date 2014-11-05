gsub_file("app/views/layouts/application.html.erb", %r{, 'data-turbolinks-track' => true}, '')
gsub_file("app/assets/javascripts/application.js", %r{^//= require turbolinks\n}, '')
remove_file("app/assets/stylesheets/application.css")
create_file("app/assets/stylesheets/application.css.scss") do
  %q{// "bootstrap-sprockets" must be imported before "bootstrap" and "bootstrap/variables"
@import "bootstrap-sprockets";
@import "bootstrap";}
end
append_to_file("app/assets/javascripts/application.js") do
  %q{//= require bootstrap-sprockets    
}
end

gsub_file("Gemfile", %r{^#.*}, '')
gsub_file("Gemfile", %r{^.*turbolinks.*}, '')
gsub_file("Gemfile", %r{^.*sdoc.*}, '')
run("sed -i.bak Gemfile -e '/^[ ]*$/d'") # remove blank lines!

gem 'therubyracer',  platforms: :ruby
gem 'haml-rails'

gem 'bcrypt', '~> 3.1.7'
gem 'unicorn'
gem 'capistrano-rails', group: :development
gem "bootstrap-sass"

gem_group :development, :test do
  gem 'pry-rails'
  gem 'pry-rescue'
  gem 'awesome_print'
  gem 'rspec-rails'
  gem 'cucumber-rails', require: false
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'quiet_assets'
  gem 'html2haml'
end

run("bundle install")

generate('rspec:install')
generate('cucumber:install')

run("bundle binstub rspec-core")
run("bundle binstub cucumber")

generate(:controller, "static_pages", "index")
insert_into_file("config/routes.rb", "  root 'static_pages#index'\n", after: %r'# root.*\n')
remove_file("app/views/static_pages/index.html.haml")
create_file("app/views/static_pages/index.html.haml") do
  %q{
.container
  .row
    %h1 Welcome!

    %p Newly generated rails app with pry-rails, rspec, cucumber, factory girl, haml, and twitter bootstrap already baked in!
}
end

create_file("features/static_pages.feature") do
  %q{Feature: Site has a static welcome page
  In order to ensure the site is assembled correctly
  As a developer
  I want the new site to have a static welcome page

  Scenario: Site has a static welcome page
    When I visit the home page
    Then I recieve an ok status
    And the page contains "Welcome"
}
end

create_file("features/step_definitions/static_pages_steps.rb") do
  %q{When(/^I visit the home page$/) do
  get '/'
end

Then(/^I recieve an ok status$/) do
  expect(last_response.status).to eq(200)
end

Then(/^the page contains "(.*?)"$/) do |arg1|
  expect(last_response.body).to have_content(arg1)
end
}
end

rake("db:create")
rake("db:migrate")

remove_file("README.rdoc")
create_file("README.md") do
  %Q{
# README

A newly generated Rails application with the following already baked in:

* pry
* rspec
* cucumber
* factory girl
* haml
* twitter bootstrap

The database you've chosen has already been created.

There is a static startup page at `/`.

Tests are run with:

    bin/rake # with no parameters

or:

    bin/rspec
    bin/cucumber

Information you should add here:

* Ruby version
* System dependencies
* Configuration
* Services (job queues, cache servers, search engines, etc.)
* Deployment instructions

}
end


git :init
git add: '.'
git commit: "-a -m 'Initial commit'"

rake("default")

say "New rails application assembled!"
