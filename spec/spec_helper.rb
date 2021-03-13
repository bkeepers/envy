require "envy"
require "pry"

module Helpers
  def fixture_path(*args)
    File.join(File.expand_path('../fixtures', __FILE__), *args)
  end

  def silence
    # Store the original stderr and stdout in order to restore them later
    original_stderr = $stderr
    original_stdout = $stdout

    # Redirect stderr and stdout
    output = $stderr = $stdout = StringIO.new

    yield

    $stderr = original_stderr
    $stdout = original_stdout

    # Return output
    output.to_s
  end
end

RSpec.configure do |config|
  config.include Helpers
end
