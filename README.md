# Envy

a schema describing and validating the environment variables needed by an application.

## Installation

Add this line to your application's Gemfile:

    gem 'envy'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install envy

## Usage

### string

A `string` is the simplest variable that can be defined.

```ruby
desc "The main external hostname."
string :host_name, :default => "example.com"
```

This defines a reader on `Envy.env.host_name` (or `Rails.application.config.host_name` for a Rails application), returning the default value if `ENV["HOST_NAME"]` is not set.

### boolean

```ruby
desc "Boolean attribute specifying whether the site is in SSL mode."
boolean :ssl, :default => true
```

This defines a reader `Envy.env.ssl?` and cast the values "0", "1", "true", or "false" into boolean values in Ruby.

### integer

`integer` will validate and cast environment variables to integers.

```ruby
desc "The max duration (in seconds) a request can take before it times out."
integer :request_timeout, :default => 10
```

### `:required`

The `:required` option can be used to enforce that a variable be defined by the environment.

```ruby
desc "A PEM of the encryption key used to encrypt sensitive data."
string :encryption_key, :required => true
```

When the `Envfile` is loaded, it will raise an exception if the required keys are not set.

```
ArgumentError: ENCRYPTION_KEY must be set in `ENV`
```

### `:default`

The `:default` option can make use of variable substitution to use existing environment variables.

```ruby
desc "The host name where the API is served from."
string :api_host_name, :default => "api.$HOST_NAME"
```

A block passed to a declaration will be called if a variable is not set and can be used to execute logic for setting the default.

```ruby
desc "Is the current environment connected to the public internet?"
boolean :online do
  check_for_internet_connection? ? google_reachable? : true
end

desc "Should a check be performed to detect if there is an internet connection?"
boolean :check_for_internet_connection?, :default => false
```

## rake env

All of this then makes it easy to inspect the environment variables available to the application.

```
$ rake env

# The main external hostname.
HOST_NAME=example.com

# Boolean attribute specifying whether the site is in SSL mode.
SSL=true

# A PEM of the encryption key used to encrypt sensitive data. (Required)
# ENCRYPTION_KEY=

# Is the current environment connected to the public internet?
# ONLINE=

# The max duration (in seconds) a request can take before it times out.
REQUEST_TIMEOUT=10

The host name where the API is served from.
API_HOST_NAME=api.$HOST_NAME
```

## Why?

So, what's the point of all this? Couldn't the same thing be accomplished with a well documented `.env` file, or a `Config` module in my app with real methods? Those would work, but an `Envfile` has the advantage that:

0. All available configuration is explicitly defined, documented and easily inspectable.
0. All configuration can be overridden by environment variables, conforming to the [Twelve-Factor App](http://12factor.net/config) methodology.
0. The manifest serves as documentation, and since it's executable and used by the application, will always be up to date.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/envy/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
