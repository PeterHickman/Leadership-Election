#!/usr/bin/env ruby
# encoding: UTF-8

require 'fileutils'

class ElectLeader
  INACTIVE_LIMIT = 5.0 # How long since a host voted (said it was alive)

  def initialize(my_name, path)
    @my_name = my_name
    @path = path

    FileUtils.mkdir_p(@path) unless File.directory?(@path)

    @nominated_hosts = []
    @active_hosts = []
  end

  def elect_the_leader
    @nominated_hosts.clear

    ##
    # We know that we are active (but we might not have written
    # our vote file yet) so we add ourselves here
    ##
    @active_hosts = [ @my_name ]

    Dir["#{@path}/*.txt"].each do |file|
      if Time.now - File.mtime(file) <= INACTIVE_LIMIT
        @nominated_hosts << IO.read(file).chomp
        @active_hosts    << File.basename(file, '.txt')
      end
    end

    ##
    # Even if it's nominated it needs to be active
    ##
    @nominated_hosts = @nominated_hosts & @active_hosts

    ##
    # If there are any nominated hosts then we will pick the first one or we
    # simply pick the first active server. This is to make sure that we don't
    # keep changing the leader for no good reason
    ##
    leader = @nominated_hosts.any? ? @nominated_hosts.sort.first : @active_hosts.sort.first

    File.open("#{@path}/#{@my_name}.txt", 'w') { |f| f.puts leader }

    leader
  end

  def current_leader?
    file = "#{@path}/#{@my_name}.txt"

    if File.exist?(file)
      if Time.now - File.mtime(file) > INACTIVE_LIMIT
        elect_the_leader
      end
    else
      elect_the_leader
    end

    IO.read(file).chomp
  end

  def am_i_the_leader?
    @my_name == current_leader?
  end
end
