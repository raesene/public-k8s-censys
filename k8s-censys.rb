#!/usr/bin/env ruby

require 'json'
require 'censys'
require 'date'

API_ID = ENV["CENSYS_API_KEY"]
SECRET = ENV["CENSYS_SECRET"]


def extract_version(key)
  full_version = key.slice(/v[0-9]\.[0-9]+\.[0-9]+/)
  major_version = full_version.slice(/v[0-9]\.[0-9]+/)
  return full_version, major_version
end
today = Date.today.to_s
git_output = File.open(today + '-k8s-versions.csv','w+')
version_output = File.open(today + '-pure-versions.csv','w+')
raw_output = File.open(today + '-k8s-version-info.json','w+')

api = Censys::API.new(API_ID,SECRET)

response = api.aggregate('services.kubernetes.version_info.git_version="*"','services.kubernetes.version_info.git_version', num_buckets: 1000)
raw_output.puts response
raw_output.close

buckets = response['result']['buckets']

sorted_buckets = Hash.new
sorted_buckets['gke'] = Array.new
sorted_buckets['eks'] = Array.new
sorted_buckets['tke'] = Array.new
sorted_buckets['iks'] = Array.new
sorted_buckets['aliyun'] = Array.new
sorted_buckets['openshift'] = Array.new
sorted_buckets['unclassified'] = Array.new

version_buckets = Hash.new

buckets.each do |bucket|
  case bucket['key']
  when /gke/
    sorted_buckets['gke'] << bucket['key'] + ',' + bucket['count'].to_s
  when /eks/
    sorted_buckets['eks'] << bucket['key'] + ',' + bucket['count'].to_s
  when /tke/
    sorted_buckets['tke'] << bucket['key'] + ',' + bucket['count'].to_s
  when /IKS/
    sorted_buckets['iks'] << bucket['key'] + ',' + bucket['count'].to_s
  when /aliyun/
    sorted_buckets['aliyun'] << bucket['key'] + ',' + bucket['count'].to_s
  when /d4cacc0/
    sorted_buckets['openshift'] << bucket['key'] + ',' + bucket['count'].to_s
  when /a0ce1bc657/
    sorted_buckets['openshift'] << bucket['key'] + ',' + bucket['count'].to_s
  when /b81c8f8/
    sorted_buckets['openshift'] << bucket['key'] + ',' + bucket['count'].to_s
  when /5115d708d7/
    sorted_buckets['openshift'] << bucket['key'] + ',' + bucket['count'].to_s
  when /a08f5eeb62/
    sorted_buckets['openshift'] << bucket['key'] + ',' + bucket['count'].to_s
  when /g41dc99c/
    sorted_buckets['openshift'] << bucket['key'] + ',' + bucket['count'].to_s
  when /43a9be4/
    sorted_buckets['openshift'] << bucket['key'] + ',' + bucket['count'].to_s
  when /776c994/
    sorted_buckets['openshift'] << bucket['key'] + ',' + bucket['count'].to_s
  when /838b4fa/
    sorted_buckets['openshift'] << bucket['key'] + ',' + bucket['count'].to_s
  when /52492b4/
    sorted_buckets['openshift'] << bucket['key'] + ',' + bucket['count'].to_s
  when /d8ef5ad/
    sorted_buckets['openshift'] << bucket['key'] + ',' + bucket['count'].to_s
  when /9caf8fe/
    sorted_buckets['openshift'] << bucket['key'] + ',' + bucket['count'].to_s
  when /7d0a2b2/
    sorted_buckets['openshift'] << bucket['key'] + ',' + bucket['count'].to_s
  when /df9c838/
    sorted_buckets['openshift'] << bucket['key'] + ',' + bucket['count'].to_s
  when /a8c5f5b/
    sorted_buckets['openshift'] << bucket['key'] + ',' + bucket['count'].to_s
  when /b758672/
    sorted_buckets['openshift'] << bucket['key'] + ',' + bucket['count'].to_s
  when /c62ce01/
    sorted_buckets['openshift'] << bucket['key'] + ',' + bucket['count'].to_s
  when /d7721aa/
    sorted_buckets['openshift'] << bucket['key'] + ',' + bucket['count'].to_s
  when /3107688/
    sorted_buckets['openshift'] << bucket['key'] + ',' + bucket['count'].to_s
  when /cdb0358/
    sorted_buckets['openshift'] << bucket['key'] + ',' + bucket['count'].to_s
  when /7070803/
    sorted_buckets['openshift'] << bucket['key'] + ',' + bucket['count'].to_s
  else
    sorted_buckets['unclassified'] << bucket['key'] + ',' + bucket['count'].to_s
  end
end

sorted_buckets.each do |bucket, data|
  data.each do |item|
    git_output.puts bucket + ',' + item
  end
end

buckets.each do |bucket|
  begin
    full_version, major_version = extract_version(bucket['key'])
  rescue
    puts "Had an error on " + bucket['key']
    next
  end
  unless version_buckets[major_version]
    version_buckets[major_version] = Hash.new
  end
  unless version_buckets[major_version][full_version]
    version_buckets[major_version][full_version] = 0
  end
  version_buckets[major_version][full_version] = version_buckets[major_version][full_version] + bucket['count']
end

version_buckets.each do |major_version, full_version|
  full_version.each do |ver,count|
    version_output.puts major_version + ',' + ver + ',' + count.to_s
  end
end

