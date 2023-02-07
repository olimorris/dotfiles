require 'rake'

def section(title, _description = '')
  seperator_count = (80 - title.length) / 2
  puts ("\n" + '=' * seperator_count) + title.upcase + ('=' * seperator_count)
  puts '~> Performing as dry run' if ENV['DRY_RUN']
  puts '~> Performing as super user' if ENV['SUDO']
  puts '~> Performing as test env user' if ENV['TEST_ENV']
end

def run(cmd)
  puts "~>#{cmd}"

  calling_file = File.basename(caller_locations[0].path)
  if ENV['TEST_ENV']
    if testable?(calling_file)
      system cmd unless ENV['DRY_RUN']
    else
      puts "~> Skipped for #{calling_file}"
    end
  else
    system cmd unless ENV['DRY_RUN']
  end
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

def find_replace(file_name, find, replace)
  file_name_new = file_name.gsub('~', ENV['HOME'])
  text = File.read(file_name_new)
  new_text = text.gsub(find, replace)

  # To write changes to the file, use:
  File.open(file_name_new, 'w') { |file| file.puts new_text }
end
