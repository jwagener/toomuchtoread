# TooMuchToRead

a simple search interface for project gutenberg books.

# Index

The index is just a simple tab-seperated text file called 'sorted-index'
It's format is: 
[download count]\t[gutenberg id]\t[title]\t[author]

It needs to be ordered in the way the results should be returned.
So for Project Gutenberg it's simple sorted by the download count.

There is a script that converts the Gutenberg catalog.rdf:
$ ./parse-catalog.rb catalog.rdf | sort -rn > sorted-index