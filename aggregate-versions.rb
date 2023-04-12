#!/usr/bin/env ruby
require 'date'
version_output = File.new('version_results.csv','w+')
version_data = Hash.new

scan_files = Array.new
Dir.entries('.').each do |scan|
  if scan =~/pure-versions.csv$/
    scan_files << scan
  end
end

#Generate an array with all the versions held in the first column of the csv files
versions = Array.new
scan_files.each do |file|
  begin
    data = File.open(file,'r').readlines
  rescue
    puts "couldn't open " + file
    next
  end
  data.each {|line| line.chomp!}
  data.each do |line|
    versions << line.split(',')[0]
  end
end

versions.uniq!
sorted_versions = versions.sort_by do |v|
  v.scan(/\d+/).map(&:to_i)
end

sorted_versions.each {|version| version_data[version] = Hash.new}

dates = Array.new

scan_files.each do |file|
  begin
    data = File.open(file,'r').readlines
  rescue
    puts "couldn't open " + file
    next
  end
  data.each {|line| line.chomp!}
  date = file[/\d+-\d+-\d+/]
  dates << date

  data.each do |line|
    version = line.split(',')[0]
    if version_data[version][date] == nil
      version_data[version][date] = line.split(',')[2].to_i
    else
      version_data[version][date] += line.split(',')[2].to_i
    end
  end
end



#Sort Date array by oldest date to newest date
sorted_dates = dates.sort do |a,b|
  Date.parse(a) <=> Date.parse(b)
end

#put all the dates in the first row
version_output.print ','
version_output.puts sorted_dates.join(',')

version_data.each do |version, data|
  version_output.print version
  sorted_dates.each do |date|
    version_output.print ',' + data[date].to_s
  end
  version_output.puts
end