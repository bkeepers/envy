require "envy"

module Fixtures
  def fixture_path(name)
    File.join(File.expand_path('../fixtures', __FILE__), name)
  end
end

RSpec.configure do |config|
  config.include Fixtures
end
