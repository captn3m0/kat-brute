#kat-brute

Internal stuff for SDSLabs.

##Setup

	wget https://kickass.to/dailydump.txt.gz
    gunzip dailydump.txt.gz
    csvclean -d "|" dailydump.txt
    mv dailydump_out.csv data.csv
    bundle install
    ruby parse.rb

Resulting output is availble in `data.jdb`