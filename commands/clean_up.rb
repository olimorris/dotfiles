#!/usr/bin/ruby -w

require 'optparse'
require 'fileutils'

module FilesToDelete
  FILE_TYPES = %w[.avi .flv .mkv .mov .MOV .mp4 .mpg .wmv]
end

# Based on a given folder pattern, recursively run a command on all
# folders within the present working directory, outputting the
# success of each run of the command.
#
# EXAMPLE: ruby ~/.dotfiles/commands/recursive.rb -p="vendor/composer" -c="composer update"
class CleanUp

  include FilesToDelete

  attr_accessor :count, :failure, :folder, :success

  def initialize(folder)
    @count = 0
    @failure = 0
    @success = 0
    @folder = folder
    setup
  end

  def setup
    if ! @folder
      puts"   [✖] Please supply a folder"
      abort
    end

    clean
  end

  def clean
    @folder.sub! '~', ENV['HOME']

    Dir.foreach(@folder) do |item|
      if FILE_TYPES.include? File.extname(item)

        FileUtils.rm("#{@folder}/#{item}")

        if ! File.exist?("#{@folder}/#{item}")
          puts "   [✔] #{item} was deleted"
        else
          puts "   [✖] #{item} was not deleted"
        end
      end
    end
    
  end
end

CleanUp.new(ARGV[0].dup)
