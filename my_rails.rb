gsub_file("app/views/layouts/application.html.erb", %r{, 'data-turbolinks-track' => true}, '')
gsub_file("app/assets/javascripts/application.js", %r{^//= require turbolinks\n}, '')
remove_file("app/assets/stylesheets/application.css")
create_file("app/assets/stylesheets/application.css.scss") do
  %q{
// Set up template for sticky footer and fixed top navbar
$footer_height: 60px;

// "bootstrap-sprockets" must be imported before "bootstrap" and "bootstrap/variables"
@import "bootstrap-sprockets";
@import "bootstrap";

.footer {
    position: absolute;
    bottom: 0;
    width: 100%;
    /* Set the fixed height of the footer here */
    height: $footer_height;
    background-color: #f5f5f5;

    > .container {
        padding-top: 20px;
        padding-right: 15px;
        padding-left:  15px;
    }
}

body {
    margin-bottom: $footer_height;

    > .container {
        padding: $navbar_height 15px;
    }
}
}
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
gem "fontawesome-rails"
gem "twitter_bootstrap_form_for", github: "tamouse/twitter_bootstrap_form_for"

gem_group :development, :test do
  gem 'pry-rails'
  gem 'pry-byebug'
  gem 'awesome_print'
  gem 'rspec-rails'
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'quiet_assets'
  gem 'html2haml'
end

run("bundle install")

generate('rspec:install')
run("bundle binstub rspec-core")

generate(:controller, "static_pages", "index", "--no-helper", "--no-assets", "--no-view-specs")
route("root 'static_pages#index'")

remove_file("app/views/static_pages/index.html.haml")
create_file("app/views/static_pages/index.html.haml") do
  %q{
.jumbotron
  .container
    %h1 Welcome!

    %p Newly generated rails app with pry-rails, rspec, factory girl, haml, and twitter bootstrap already baked in!
}
end


run("bundle exec html2haml app/views/layouts/application.html.erb app/views/layouts/application.html.haml")
insert_into_file("app/views/layouts/application.html.haml",%q{
    = render partial: "header"
    = render partial: "flash_area"

    .container
  }, before: %r{\n.*= yield})
append_to_file("app/views/layouts/application.html.haml", %q{
    = render partial: "footer"
})
remove_file("app/views/layouts/application.html.erb")

empty_directory("app/views/application/")
create_file("app/views/application/_header.html.haml", %q{.navbar.navbar-default{role: "navigation"}
  .container-fluid
    .navbar-header
      %button.navbar-toggle.collapsed{type: "button", data: {toggle: "collapse", target: "#navbar-collapse-1"}}
        %span.sr-only Toggle navigation
        %span.icon-bar
        %span.icon-bar
        %span.icon-bar
      %a.navbar-brand{href: root_path} New Rails App

    .collapse.navbar-collapse#navbar-collapse-1
      %ul.nav.navbar-nav
        %li= link_to "Welcome", static_pages_index_path

})

create_file("app/views/application/_footer.html.haml", %Q{
%footer.footer.bg-info
  .container
    .text-muted.text-center Copyright &copy; #{Time.now.year} Tamara Temple Web Development
})

create_file("app/views/application/_flash_area.html.haml", %Q{- if flash.any?
  = flash_display
})

insert_into_file("app/helpers/application_helper.rb", %q{

  def flash_display
    content_tag(:div, class: "container") do
      flash.each do |level, message|
        concat(content_tag(:div, message, class: "alert alert-#{flash_level_to_bootstrap(level)}"))
      end
    end
  end

  def flash_level_to_bootstrap(level)
    case level
    when "alert"
      "danger"
    else
      "info"
    end
  end

}, before: "end")

rake("db:create")
rake("db:migrate")

remove_file("README.rdoc")
create_file("README.md") do
  %Q{
# README

A newly generated Rails application with the following already baked in:

* pry
* rspec
* factory girl
* haml
* twitter bootstrap
* additional support for twitter bootstrap form building

The database you've chosen has already been created.

There is a static startup page at root.

Tests are run with:

    bin/rake # with no parameters

or:

    bin/rspec

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
