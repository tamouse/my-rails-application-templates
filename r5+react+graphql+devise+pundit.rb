# run with --skip-spring --skip-turbolinks --skip-bundle

@readme = "README.md"

remove_file(@readme)
create_file(@readme)
app_description = ask("Describe your rails app in one line:")
append_to_file(@readme) do <<-"README"
# #{app_description}

New rails app created with template.

README
end

if File.exist? ".ruby-version"
  ruby_version = File.read(".ruby-version")
else
  ruby_version = `ruby -v`
end

say "Created with ruby version #{ruby_version}"
append_to_file(@readme) do <<-"README"

- ruby version: #{ruby_version}

README
end

say "Adding standard development and test gems"
comment_lines("Gemfile", /coffee-rails/)
comment_lines("Gemfile", /jbuilder/)
gem_group :development, :test do
  gem "factory_bot_rails"
  gem "faker"
  gem "pry-rails"
  gem "pry-byebug"
end

run "bundle install"

append_to_file(@readme) do <<-'TEXT'

Added the following gems to the development and test contexts:

- [`factory_bot_rails`](https://github.com/thoughtbot/factory_bot) for testing factories (See: <https://devhints.io/factory_bot>)
- [`faker`](https://github.com/stympy/faker) for generating testing data
- [`pry-rails`](https://github.com/rweng/pry-rails) to run pry as the default rails console
- [`pry-byebug`](https://github.com/deivid-rodriguez/pry-byebug) to integrate pry with byebug

TEXT
end

## DEVISE
@user_created = false

if yes?("Do you want to install devise?")
  uncomment_lines("Gemfile", /bcrypt/)
  gem "devise"
  run "bundle install"
  generate "devise:install"
  application(nil, env: "development") do
    'config.action_mailer.default_url_options = { host: "localhost", port: 3000 } # Setup for devise'
  end

  uncomment_lines("config/initializers/devise.rb", /config.authentication_keys/)
  gsub_file("config/initializers/devise.rb", /:email/, ":username")
  inject_into_file 'app/views/layouts/application.html.erb', after: "<body>\n" do <<-'RUBY'
    <header class="devise-alert-header">
      <p class="notice"><%= notice %></p>
      <p class="alert"><%= alert %></p>
    </header>
RUBY
  end

  generate "controller home welcome"
  route 'root to: "home#welcome"'

  generate "task admin new"
  insert_into_file("lib/tasks/admin.rake", after: "task new: :environment do\n") do <<-'TASK'
    puts "creating admin user #{args[:username]}, password #{args[:password]}"
    User.create!(
      username: args[:username],
      admin: true,
      password: args[:password],
      password_confirmation: args[:password]
   )
TASK
  end
  gsub_file("lib/tasks/admin.rake", /desc "TODO"/, 'desc "Create a new admin user"')
  gsub_file("lib/tasks/admin.rake", /task new: :environment do/, 'task :new, [:username,:password] => :environment do |task, args|')

  generate "devise User username:string:uniq preferred_name preferred_pronouns admin:boolean"
  insert_into_file("app/models/user.rb", before: /end/) do <<-"VALIDATION"

  validates_uniqueness_of :username

  def email_required?
    false
  end

  def will_save_change_to_email?
    false
  end
VALIDATION
  end

  migration = Dir.glob("db/migrate/*_devise_create_users.rb").first
  gsub_file(migration, /t.boolean :admin/, "t.boolean :admin, null: false, default: false" )
  gsub_file(migration, /t.string :username/, "t.string :username, null: false, default: \"\"")
  gsub_file(migration, /add_index :users, :email/, "add_index :users, :username")
  rake "db:migrate"

  generate "devise:views"
  %w[app/views/devise/sessions/new.html.erb app/views/devise/registrations/new.html.erb app/views/devise/registrations/edit.html.erb].each do |file|
    gsub_file(file, /email_field/, "text_field")
    gsub_file(file, /email/, "username")
  end

  @user_created = true

  rake "admin:new[admin,admin123]"

  say "Devise is installed"

  append_to_file(@readme) do <<-"TEXT"

Added [`devise`](https://github.com/plataformatec/devise) and created User model. Additional fields in the User model:

- `username` [String] - a username
- `preferred_name` [String] - the user's preferred name
- `preferred_pronouns` [String] - the user's preferred pronouns, e.g. "she/her/hers", "they/them/theirs", etc.
- `admin` [Boolean] - whether the user is an admin or not. Boolean forced to bi-state by setting `null: false` in the migration. The default is `false`.

The default route `root` is set to `home#welcome`. You may want to modify `app/views/home/welcome.html.erb`

User model created: #{@user_created}

TEXT
  end

end


## PUNDIT

if @user_created && yes?("Do you want to install pundit?")
  gem "pundit"
  run "bundle install"
  generate "pundit:install"
  generate "pundit:policy User"
  append_to_file(@readme) do <<-'TEXT'

Added [`pundit`](https://github.com/varvet/pundit) and initialized. Created User policy in `app/policies/user_policy.rb`. You should update the user policy for your needs. The default application policy is fully restricted.

TEXT
  end
end

## GRAPHQL

if yes?("Do you want to install graphql?")
  gem "graphql"
  run "bundle install"
  generate "graphql:install"
  run "bundle install"

  say "injecting methods into Types::BaseObject class"
  inject_into_class "app/graphql/types/base_object.rb", 'Types::BaseObject' do <<-'METHODS'

    def created_at_ms
      time_to_ms(object.created_at)
    end

    def updated_at_ms
      time_to_ms(object.updated_at)
    end

    def time_to_ms(time)
      (time.to_f * 1000).to_i
    end

METHODS

  end


  say "Injeccting methods into Types::BaseInputObject class"
  inject_into_class "app/graphql/types/base_input_object.rb", 'Types::BaseInputObject' do <<-'METHODS'

    def ms_to_time(ms)
      Time.at(ms / 1000.0).utc
    end

METHODS
  end

  if @user_created
    generate "graphql:object UserGraph id:!Int email:!String username:String preferred_name:String preferred_pronouns:String admin:!Boolean created_at:!DateTime created_at_ms:!Int updated_at:!DateTime updated_at_ms:!Int"
    gsub_file "app/graphql/types/user_graph_type.rb", /Types::DateTimeType/, "GraphQL::Types::ISO8601DateTime"
  end

  append_to_file(@readme, "\n\nAdded [GraphQL](http://graphql-ruby.org/) and initialized.\n")

  if @user_created
    append_to_file(@readme) do <<-"TEXT"

Created `Types::UserGraphType` with fields:

- `id`
- `email`
- `username`
- `preferred_name`
- `preferred_pronouns`
- `admin`
- `created_at` and `created_at_ms`
- `updated_at` and `updated_at_ms`


TEXT
    end
  end
end

## REACT

if yes?("Do you want to install webpacker and react-rails?")

  gem "webpacker"
  gem "react-rails"
  run "bundle install"
  rake "webpacker:install"
  rake "webpacker:install:react"
  generate "react:install"
  inject_into_file 'app/views/layouts/application.html.erb', after: "<%= javascript_include_tag 'application' %>\n" do <<-'RUBY'
    <%= javascript_pack_tag    'application' %>
RUBY
  end

  run "yarn upgrade"

  if @user_created
    generate "react:component display_user user:object"
    gsub_file("app/javascript/components/DisplayUser.js", /{this.props.user}/, "<pre><code>{JSON.stringify(this.props.user, {}, 2)}</code></pre>")
    append_to_file("app/views/home/welcome.html.erb") do <<-'REACT'
<%= react_component("DisplayUser", user: User.first) %>
REACT
    end
  end

  append_to_file(@readme) do <<-'TEXT'

Added [`webpacker`](https://github.com/rails/webpacker), [`react-rails`](https://github.com/reactjs/react-rails), initialized them both, and added the `application` pack to the default application layout.  You can now build react components for inclusion in standard rails views in `app/javascript/components/`. You can put regular javascript source in `app/javascript/src/` to be imported or required in react components.

TEXT
  end

  if @user_created
    append_to_file(@readme) do <<-"TEXT"
- Created `DisplayUser` component, appended to `app/views/home/welcome.html.erb`

TEXT
    end
  end


  if yes?("Do you want to install apollo client?")
    run "yarn add apollo-boost react-apollo graphql "

    append_to_file(@readme) do <<-'TEXT'

Added apollo client libraries to `package.json`:

- `apollo-boost` for the most common set of apollo client libraries
- `react-apollo` for using apollo client with react
- `graphql` for creating query documents

See the [apollo client docs](https://www.apollographql.com/docs/react/) for more info on using apollo client

TEXT
    end
    say "You may want to update `config/webpacker.yml` to include the ability for webpack to automatically load `.graphql` files."
  end

end
