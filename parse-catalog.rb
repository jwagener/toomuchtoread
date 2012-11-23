#!/usr/bin/env ruby
# run as:
# $ ./parse-catalog.rb catalog.rdf | sort -rn > sorted-index

require 'xml'
parser = XML::Parser.file(ARGV.first); nil
doc = parser.parse; nil
i = 0
doc.root.find("pgterms:etext").each do |node|
  begin
    id = node.attributes.first.value.gsub("etext", "")
    t = node.find("dc:title")
    title = t[0] ? t[0].content : ""
    title = title.split("\n").join(" ")
    c = node.find("dc:creator")
    creator = c[0] ? c[0].content : ""
    creator = creator.split("\n").join(" ")
    sc = creator.split(",")
    creator = [(sc[1] unless (sc[1] || "").match(/\d/) ), sc[0]].join(" ")
    downloads = node.find("pgterms:downloads")[0].children[0].children[0].content
    #STDERR << "#{id+=1} #{id}\n"; nil
    puts [downloads, id, title, creator].join("\t")
    STDOUT.flush()
  rescue Exception => e
    id = node.attributes.first.value.gsub("etext", "")
    STDERR << "Ex #{id}: #{e}\n" #{$!} #{node}"; nil
  end
end