# Envy

**Heads Up!** _This project is currently in alpha. It is not actively used or maintained, so proceed with caution!_

a schema describing and validating the environment variables needed by an application.

Envy reads the schema from an `Envfile` when an application bootstraps and:

0. declares the variables available to the application
0. validates required variables
0. casts values
0. sets default values
0. creates reader methods that fetch values from `ENV`

## Installation

Add this line to your application's Gemfile:

```ruby
gem "envy", github: "bkeepers/envy"
```

And then execute:

```
$ bundle
```

## Usage

Create an `Envfile` in the root of your application.

```ruby
desc "Support email shown on the contact page."
string :support_email, :default => "support@example.com"

desc "The max duration (in seconds) a request can take before it times out."
integer :request_timeout, :default => 10

desc "Boolean attribute specifying whether the site is in SSL mode."
boolean :ssl, :default => true
```

Every variable that is declared gets a reader method defined on `$ENV`. This reader method fetches the value from `ENV`, or falls back to a `:default` if one is defined.

```ruby
# config/application.rb
config.middleware.use RequestTimeoutMiddleware, $ENV.request_timeout

config.action_mailer.default_options = {
  from: $ENV.support_email
}

config.force_ssl = $ENV.ssl?
```

Variables can then be overridden in the environment at runtime using the variable name in `SCREAMING_SNAKE_CASE`:

```
$ REQUEST_TIMEOUT=30 rails server
```

## Types

Envy supports type casting of variable values.

### `string`

```ruby
string :support_email, :default => "support@example.com"
```

A `string` is the simplest variable that can be defined. It defines a reader on `$ENV.support_email`, returning the default value if `ENV["SUPPORT_EMAIL"]` is not set.

### `boolean`

```ruby
boolean :ssl, :default => true
```

`boolean` defines a reader `$ENV.ssl?` and cast the values "0", "1", "true", or "false" into boolean values in Ruby.

### `integer`

```ruby
integer :request_timeout, :default => 10
```

`integer` defines a reader `$ENV.request_timeout` which validates and casts environment variables to an integer.

## Options

### `:required`

All defined variables without a default value are required. When the `Envfile` is loaded, it will raise an exception if the required keys are not set.

```
Missing environment variables: ENCRYPTION_KEY
```

The `:required` option can be set to `false` for optional values.

```ruby
string :encryption_key, :required => false
```

### `:default`

The `:default` can be used to set a default value when the variable is not defined in `ENV`.

```ruby
integer :request_timeout, :default => 10
```

If logic is required to set a default, a block can be passed to a declaration and it will be called if a variable is not set in `ENV`.

```ruby
boolean :check_for_internet_connection?, :default => false

boolean :online do
  check_for_internet_connection? ? Site.google_reachable? : true
end
```

## Why?

So, what's the point of all this? Couldn't the same thing be accomplished with a well documented `.env` file, or a `Config` module in my app with real methods? Those would work, but an `Envfile` has the advantage that:

0. All available configuration is explicitly defined, documented and easily inspectable.
0. All configuration can be overridden by environment variables, conforming to the [Twelve-Factor App](http://12factor.net/config) methodology.
0. The manifest serves as documentation, and since it's executable and used by the application, will always be up to date.

## Contributing

1. Fork it ( https://github.com/bkeepers/envy/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
