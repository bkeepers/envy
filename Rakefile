require "bundler/gem_tasks"

# namespace 'envy' do
#   Bundler::GemHelper.install_tasks :name => 'envy'
# end
#
# namespace 'envy-rails' do
#   class DotenvRailsGemHelper < Bundler::GemHelper
#     def guard_already_tagged; end # noop
#     def tag_version; end # noop
#   end
#
#   DotenvRailsGemHelper.install_tasks :name => 'envy-rails'
# end
#
# task :build => ["envy:build", 'envy-rails:build']
# task :install => ["envy:install", 'envy-rails:install']
# task :release => ["envy:release", 'envy-rails:release']

require 'rspec/core/rake_task'

desc "Run all specs"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = %w[--color]
  t.verbose = false
end

task :default => :spec
