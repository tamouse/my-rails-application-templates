# THIS REPO IS FAR OUT OF DATE

## It has not been updated for Rails 5

# My Rails Application Template

This template is how I like to have new rails applications set up.

* no spring, no turbolinks
* pry, with debugging and console support
* rspec
* factory girl, faker
* haml
* twitter bootstrap, in sass form
* additional support for tbs horizontal form builders
* startup page at root

## Usage:

    $ rails new --skip-bundle --skip-test-unit --skip-spring --skip-turbolinks -m my_rails.rb

Other `rails new` options still work as well, such as `--database` and so on.

## Other templates

* `example_app.rb` - I use this for setting up quick learning and test examples
* `my_rails_with_devise.rb` - adds and configures devise and pundit

*... more to come!*

## Installation

    $ git clone git@github.com:tamouse/my-rails-application-templates.git $HOME/.railsrc.d

## Configuration

Create `$HOME/.railsrc` and add the following:

```
--skip-bundle --skip-test-unit --skip-spring --skip-turbolinks -m <$HOME>/.railsrc.d/my_rails.rb
```

You have to put your actual path to $HOME rather than being able to
use the envar, so it really looks something like:

```
--skip-bundle --skip-test-unit --skip-spring --skip-turbolinks -m /home/tamouse/.railsrc.d/my_rails.rb
```
