#!/usr/bin/env ruby

require 'rubygems'  # not necessary for Ruby 1.9
require 'mongo'

# Connect to db. Located here to make it easy to change port etc...
db = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'dms_sample')

# Load data from the file
fname = ARGV.first || './data/name_data.sql'

puts "loading name data from: " + fname

name_hash = {}
File.open(fname).each_with_index do |r,idx|

  unless r.chomp.empty?
    r =  r.slice(r.rindex('values (') +8, r.length).strip.chomp(');')  

    vals = r.split(',').map{ |v| v.sub(/'/,'').chomp("'") }
    vals = vals.map{ |v| v == vals[0] ? v.to_sym : v }

    if name_hash[vals[0]] 
      name_hash[vals[0]] << vals[1]
    else
      name_hash[vals[0]] = [vals[1]]
    end

  end
end

# Load Mongo collection
name_data = db[:name_data]
result = name_data.drop
result = name_data.insert_one(name_hash)
puts "inserted: " + result.n.to_s + " name records"
