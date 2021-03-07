# Envy

a schema describing and validating the environment variables needed by an application.

## Why?

1. All available configuration is explicitly defined, documented and easily inspectable.
2. All configuration can be overridden by environment variables, conforming to the [Twelve-Factor App](http://12factor.net/config) methodology.
3. The schema serves as documentation, and since it's executable and used by the application, will always be up to date.

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
string :support_email, default: "support@example.com"

desc "The max duration (in seconds) a request can take before it times out."
integer :request_timeout, default: 10

desc "Boolean attribute specifying whether the site is in SSL mode."
boolean :ssl, default: Rails.env.production?
```

Envy reads the schema when the application bootstraps and:

1. Defines `$ENV` with reader methods for each variable that fetch values from `ENV`
2. Validates required environment variables, raising an error if any are missing
3. Casts values
4. Sets `:default` values

You can access the environment through `$ENV`.

```ruby
# For example, in config/application.rb
config.action_mailer.default_options = {
  from: $ENV.support_email
}

config.force_ssl = $ENV.ssl?
```

Variables can be set in the environment at runtime using the variable name in `SCREAMING_SNAKE_CASE`:

```
$ REQUEST_TIMEOUT=30 rails server
```

## Types

Envy supports type casting of variable values.

### `string`

```ruby
string :support_email, default: "support@example.com"
# >> $ENV.support_email
# => "support@example.com"
```

### `boolean`

```ruby
boolean :ssl, default: true
# >> $ENV.ssl?
# => true
```

### `integer`

```ruby
integer :request_timeout, default: 10
# >> $ENV.request_timeout
# => 10
```

### `decimal`

```ruby
decimal :sample_rate, default: 0.1
# >> $ENV.sample_rate
# => 0.1
```

### `uri`

```ruby
uri :app_host, default: "https://example.com
# >> $ENV.app_host
# => #<Addressable::URI:0x1040 URI:https://example.com>
```

### Custom types

Declare your own types by extending [`Envy::Type::Variable`](lib/envy/type/variable.rb) and implementing `#cast`.

```ruby
class MyType < Envy::Type::Variable
  def cast(value)
    # return cast value here
  end
end

type :my_type, MyType

desc "My custom variable type"
my_type :var_name
```

## Options

### `:required`

All defined variables without a default value are required. When the `Envfile` is loaded, it will raise an exception if the required keys are not set.

```
Missing environment variables: ENCRYPTION_KEY
```

The `:required` option can be set to `false` for optional values.

```ruby
string :encryption_key, required: false
```

### `:default`

The `:default` can be used to set a default value when the variable is not defined in `ENV`.

```ruby
integer :request_timeout, default: 10
```

If logic is required to set a default, a block can be passed to a declaration and it will be called if a variable is not set in `ENV`.

```ruby
boolean :check_for_internet_connection?, default: false

boolean :online do
  check_for_internet_connection? ? Site.google_reachable? : true
end
```

## Contributing

1. Fork it ( https://github.com/bkeepers/envy/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
