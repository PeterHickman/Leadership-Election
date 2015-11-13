require 'logger'
require 'fileutils'

require 'elect_leader'

##
# Each machine in the cluster need to be uniquely identified. For me the
# short host name is good enough.
##

my_name = `hostname -s`.chomp

logger = Logger.new('elect_leader.log')
logger.formatter = Logger::Formatter.new

logger.info "Starting to elect a leader by #{my_name}"

el = ElectLeader.new(my_name, '/path/to/nfs/mount/')

old_leader = nil
last_logger = Time.at(0)

loop do
  leader = el.elect_the_leader

  if leader != old_leader
    if old_leader == nil
      logger.info "Initial leader is #{leader}"
    else
      logger.info "Change of leadership, is now #{leader}"
    end
    old_leader = leader
    last_logger = Time.now
  elsif Time.now - last_logger > 60.0
    logger.info "Current leader is #{leader}" 
    last_logger = Time.now
  end

  sleep 4
end
