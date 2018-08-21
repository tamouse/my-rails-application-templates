# My Rails Application Templates

I spin up toy rails apps from time to time to try things out, make a demo, work out some particularly knotty problem with work, and so on. I like to have a few things happening in an app straight off.


* no spring, no turbolinks
* pry, with debugging and console support
* factory bot (rails), faker
* startup page at root

Some additional things that some of the templates have:

* devise, pundit
* webpacker, react-rails
* graphql-ruby, react-apollo

## Usage:

    $ rails new app --skip-bundle --skip-test-unit --skip-spring --skip-turbolinks -m <template_file>

Other `rails new` options still work as well, such as `--database` and so on.

## How I set things up

Create `$HOME/.railsrc` and add the following:

```
--skip-bundle --skip-test-unit --skip-spring --skip-turbolinks
```

Clone this into `$HOME/.railsrc.d`

Then:

    $ rails new app -m ~/.railsrc.d/<template_file>
