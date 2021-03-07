require "envy"
require "pry"

module Fixtures
  def fixture_path(*args)
    File.join(File.expand_path('../fixtures', __FILE__), *args)
  end
end

RSpec.configure do |config|
  config.include Fixtures
end
