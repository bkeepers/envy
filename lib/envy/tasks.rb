desc "Show environment variables that the application uses."
task :env do
  Envy.environment.each do |variable|
    description = variable.options[:description]

    puts description.gsub(/^/m, "# ") if description
    puts "# #{variable.from}=#{variable.default}"
    puts
  end
end
