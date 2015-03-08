#kat-brute

Internal stuff for SDSLabs.

#Setup

	git clone git@github.com:captn3m0/kat-brute.git
    bundle install

##Production Data

**Note**: This is network and storage intensive. Don't run locally

    # You can use wget, but its pretty slow
    sudo apt-get install axel -y
    axel -n 10 -a https://kickass.to/dailydump.txt.gz
    gunzip dailydump.txt.gz
    # Converts the ugly dump to valid csv
    ruby setup.rb

##Development Data
Since the production dataset is huge, we can test against smaller dataset (available in repo)

    gunzip tiny.csv.gz
    mv tiny.csv data.csv

#Parser
    # Converts data.CSV to our required dataset
    ruby parse.rb

Resulting output is availble in `data.jdb`. In case you just want the final dataset,
a sample dataset can be found in `sample.jdb.gz`.

