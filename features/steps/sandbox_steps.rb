# the following code appears in "config/environment.rb" after /Rails::Initializer.run/:
Given /^the following code appears in "([^\"]*)" after \/([^\\\/]*)\/:$/ do |file_name, regex, content|
  regex = Regexp.new(regex)
  in_current_dir do
    content_lines = File.read(file_name).split("\n")
    0.upto(content_lines.length - 1) do |line_index|
      if regex.match(content_lines[line_index])
        content_lines.insert(line_index + 1, content)
        break
      end
    end
    File.open(file_name, 'wb') { |f| f << (content_lines * "\n") }
  end
end

When /^I run this in the background: (spork|spec|cucumber)(| .*)$/ do |command, args|
  @background_script = run_in_background(localized_command(command, args))
end

When /^I fire up a spork instance with "spork(.*)"$/ do |spork_opts|
  @spork_server = run_in_background(localized_command("spork", spork_opts))

  output = ""
  begin
    status = Timeout::timeout(15) do
      # Something that should be interrupted if it takes too much time...
      while line = @spork_server.stderr.gets
        output << line
        puts line
        break if line.include?("Spork is ready and listening")
      end
    end
  rescue Timeout::Error
    puts "I can't seem to launch Spork properly.  Output was:\n#{output}"
    true.should == false
  end
end

Then /^the spork window should output a line containing "(.+)"/ do |expected|
  output = ""
  begin
    status = Timeout::timeout(5) do
      # Something that should be interrupted if it takes too much time...
      while line = @spork_server.stdout.gets
        output << line
        puts line
        break if output.include?(expected)
      end
    end
  rescue Timeout::Error
    output.should include(expected)
  end
end

When /^I type this in the spork window: "(.+)"/ do |line|
  @spork_server.stdin.puts(line)
  @spork_server.stdin.flush
end

# TODO remove this when Aruba background job support is stable
Then /^the background job output should contain "(.*)"$/ do |text|
  last_background_job_stdout.should include(text)
end
