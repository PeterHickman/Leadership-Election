# Leadership-Election
I have several servers but I need it that only one machine takes on the role as a leader to perform particular functions. The only form of communication is a common directory (an NFS mount for example).

Each machine writes a file to the common area saying who it thinks is the current leader. They then, individually, read all the votes and work out who the leader really is and write a new file with the new leader. If there appears to be no suitable leader they will vote for themselves (they know that they are at least active).

This very quickly brings all the machines into consensus and is stable in that it does not change the leader unless the leader becomes inactive.

# Running it

To use it you need to run a process like `who_is_the_leader.rb` which runs the voting process every four seconds.

For the processes that needs to know if they can run then something like `example_process.rb` should fit the bill.

# Notes

There is a link between the frequency that `who_is_the_leader.rb` polls and the `INACTIVE_LIMIT` in the `elect_leader.rb` file. If machines are being incorrectly being flagged as inactive then either increase the value of `INACTIVE_LIMIT` or poll more frequently. But these values work for me.

# Limitations

I have not had this run with more than 5 servers. It works well but I'm not too sure that this would scale well.

Obviously if the NFS mount fails then it will all go south :(
