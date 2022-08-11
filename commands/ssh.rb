#!/usr/bin/ruby -w

# This command generates a new SSH key, saves it into $HOME/.ssh, copies the
# public key to the clipboard before deleting it rom the computer. The
# command also adds the relevant data to the ~/.ssh/config file

$LOAD_PATH.unshift(File.dirname(__FILE__).to_s)

puts 'Q. What is the alias for this key? (e.g. GitHub): '
host_alias = gets.chomp

puts 'Q. What is the host name or the host IP?: '
host_name = gets.chomp

puts 'Q. What is the username assigned to this key?: '
user_name = gets.chomp

ssh_key_content = "\n" \
"Host #{host_alias}\n" \
"HostName #{host_name}\n" \
"User #{user_name}\n" \
"IdentityFile ~/.ssh/#{host_alias}"

# Now let's make the key
system "(ssh-keygen -t rsa -b 4096 -C \"#{user_name}\" -f \"#{ENV['HOME']}/.ssh/#{host_alias}\" &> /dev/null)"

# And let's add the ssh key to the config file
open("#{ENV['HOME']}/.ssh/config", 'a') do |f|
  f.puts ssh_key_content
  puts '~> Added key to ~/.ssh/config file'
end

# Copy the public key to the clipboard
system "(pbcopy < \"#{ENV['HOME']}/.ssh/#{host_alias}.pub\" &> /dev/null)"
puts '~> Copied key to clipboard'

# And remove it from the computer for security purposes
system "(rm \"#{ENV['HOME']}/.ssh/#{host_alias}.pub\" &> /dev/null)"
puts '~> Removed public key from ~/.ssh folder'
