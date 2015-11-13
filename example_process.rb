require 'elect_leader'

TILL_NEXT_UPDATE = 60 * 15

logger = Logger.new('example_process.log')
logger.formatter = Logger::Formatter.new

next_run = Time.at(0)

my_name = `hostname -s`.chomp

el = ElectLeader.new(my_name, '/path/to/nfs/mount/')

loop do
  if el.am_i_the_leader?
    if next_run < Time.now
      logger.info "I am the leader so I will collect this data"

      begin
        ##
        # Do the work!!!
        ##
      rescue Exception => e
        logger.error "Processing exited unexpectedly: #{e}"
        e.backtrace.each { |line| logger.warn line }
      end

      next_run = Time.now + TILL_NEXT_UPDATE

      logger.info "Sleeping until #{next_run}"
    end
  else
    logger.info "I am not the leader, I will sit this out"
    ##
    # To make sure that the process runs the moment that we become the leader
    ##
    next_run = Time.now(0)
  end

  sleep 60
end
