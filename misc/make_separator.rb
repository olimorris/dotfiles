def separator(title, spacer, vim)
    if ! defined?(spacer) or spacer == nil or spacer.length == 0
        spacer = "-"
    end

    seperator_count = 80

    if vim == 's'
        vim_start = " {{{"
        seperator_count = seperator_count - vim_start.length
    end
    if vim == 'e'
        vim_end = " }}}"
        seperator_count = seperator_count - vim_end.length
    end
    seperator_count = (seperator_count - title.length) / 2
    seperator =  spacer*seperator_count + title.upcase + (spacer*seperator_count + (vim_start ? vim_start : '') + (vim_end ? vim_end : ''))

    puts ("\n" + (seperator.length.odd? ? spacer : '') + seperator)
end

puts "Enter your desired title: "
title = gets.chomp

puts "Which character should make up the separator? (- is default): "
spacer = gets.chomp

puts "Include Vim fold? (s for starting fold, e for ending fold, blank for nothing): "
vim = gets.chomp

puts separator(title, spacer, vim)