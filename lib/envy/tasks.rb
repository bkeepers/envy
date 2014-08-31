desc "Show environment variables that the application uses."
task :env do
  Envy.env.each do |variable|
    description = variable.options[:description]
    next unless description

    puts description.gsub(/^/m, "# ")
    puts "# #{variable.from}=#{variable.default}"
    puts
  end
end
