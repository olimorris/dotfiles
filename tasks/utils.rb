require 'rake'

# Commands that failed but weren't fatal. Reported together at exit so a long run
# can't end looking clean when half its steps did nothing.
FAILED_COMMANDS = []

at_exit do
  next if FAILED_COMMANDS.empty?

  puts "\n#{'!' * 80}"
  puts "~> #{FAILED_COMMANDS.length} command(s) failed:"
  FAILED_COMMANDS.each { |cmd| puts "     #{cmd}" }
  puts '!' * 80
end

def section(title, _description = '')
  seperator_count = (80 - title.length) / 2
  puts ("\n" + '=' * seperator_count) + title.upcase + ('=' * seperator_count)
  puts '~> Performing as dry run' if ENV['DRY_RUN']
  puts '~> Performing as super user' if ENV['SUDO']
  puts '~> Performing as test env user' if ENV['TEST_ENV']
end

# Set check: true when nothing after this command makes sense if it fails, so the
# run stops at the real cause. Everything else reports and carries on - installing
# a list of packages shouldn't abort because one of them has been renamed.
def run(cmd, check: false)
  puts "~>#{cmd}"

  calling_file = File.basename(caller_locations[0].path)
  if ENV['TEST_ENV'] && !testable?(calling_file)
    puts "~> Skipped for #{calling_file}"
    return
  end
  return if ENV['DRY_RUN']

  # `system` returns false on a non-zero exit and nil if the command couldn't be run
  # at all. Neither was checked before, so a failed step printed its command and the
  # run carried on regardless.
  return true if system(cmd)

  raise "Command failed: #{cmd.strip}" if check

  puts "~> FAILED: #{cmd.strip}"
  FAILED_COMMANDS << cmd.strip
  false
end

def yesno?(question)
  require 'highline/import'
  exit unless HighLine.agree(question)
end

def testable?(filename)
  !SKIP_TESTS_FOR.include?(filename)
end

def testing?
  ENV['TEST_ENV']
end

def personal_machine?
  `scutil --get ComputerName`.strip == "Oli's MacBook Pro"
end

def find_replace(file_name, find, replace)
  file_name_new = file_name.gsub('~', ENV['HOME'])
  text = File.read(file_name_new)
  new_text = text.gsub(find, replace)

  # To write changes to the file, use:
  File.open(file_name_new, 'w') { |file| file.puts new_text }
end
