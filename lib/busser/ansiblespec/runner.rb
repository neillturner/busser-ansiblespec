#!/usr/bin/env ruby
# -*- encoding: utf-8 -*-
#
# Author:: HIGUCHI Daisuke (<d-higuchi@creationline.com>)
#
# Copyright (C) 2013-2014, HIGUCHI Daisuke
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'rake'
require 'rspec/core/rake_task'
require 'rbconfig'
require 'yaml'

base_path = File.expand_path(ARGV.shift)
kitchen_path = '/tmp/kitchen'
kitchen_path = ENV['KITCHEN_PATH'] if ENV['KITCHEN_PATH']
playbook = 'default.yml'
playbook = ENV['PLAYBOOK'] if ENV['PLAYBOOK']
hosts = 'hosts'
hosts = ENV['INVENTORY'] if ENV['INVENTORY']
pattern = 'ansiblespec'
pattern = ENV['PATTERN'].downcase if ENV['PATTERN']


playbook_file = YAML.load_file("#{kitchen_path}/#{playbook}")
properties = {}
keys = 0

playbook_file.each do |item|
  ansible_hosts = item['hosts'].split(',')
  ansible_roles = item['roles']
  hostnames = false
  ansible_hosts.each do |h|
    begin
      `ansible #{h} --list-hosts -i #{kitchen_path}/#{hosts}`.lines do |line|
        keys += 1
        properties["host_#{keys}"] = {:host => line.strip, :roles => ansible_roles}
        puts "group: #{h} host: #{line.strip!} roles: #{ansible_roles}"
        hostnames = true
      end
    rescue
    end
    if !hostnames
      keys += 1
      properties["host_#{keys}"] = {:host => h, :roles => ansible_roles}
      puts "no group so using host: #{h} roles: #{ansible_roles}"
    end
  end
end

desc "Run serverspec to hosts"
task :spec => 'serverspec:all'

base_path = File.expand_path(ARGV.shift)

namespace :serverspec do
  task :all => properties.keys.map {|key| 'serverspec:' + key }
  properties.keys.each do |key|
    desc "Run serverspec #{key} for #{properties[key][:host]}"
    puts "-----> Run serverspec #{key} for host: #{properties[key][:host]} roles: #{properties[key][:roles]}"
    RSpec::Core::RakeTask.new(key.to_sym) do |t|
      candidate_bindirs = []
      # Current Ruby's default bindir
      candidate_bindirs << RbConfig::CONFIG['bindir']
      # Search all Gem paths bindirs
      candidate_bindirs << Gem.paths.path.map do |gem_path|
        File.join(gem_path, 'bin')
      end
      candidate_rspec_bins = candidate_bindirs.flatten.map do |bin_dir|
        File.join(bin_dir, 'rspec')
      end

      rspec_bin = candidate_rspec_bins.find do |candidate_rspec_bin|
        FileTest.exist?(candidate_rspec_bin) &&
          FileTest.executable?(candidate_rspec_bin)
      end

      t.rspec_path = rspec_bin if rspec_bin
      if pattern == 'serverspec'
        t.rspec_opts = [
          '--color',
          '--format documentation',
          "--default-path #{base_path}",
        ]
        t.ruby_opts = "-I#{base_path}"
      else
        t.rspec_opts = [
          '--color',
          '--format documentation',
          "--default-path #{kitchen_path}",
        ]
        t.ruby_opts = "-I#{kitchen_path}"
      end
     # t.pattern = "#{base_path}/**/*_spec.rb"

      ENV['TARGET_HOST'] = properties[key][:host]
      #t.pattern = 'spec/{' + properties[key][:roles].join(',') + '}/*_spec.rb'
      if pattern == 'serverspec'
        # TODO: match by role and hostname
        t.pattern = "#{base_path}/**/*_spec.rb"
      elsif pattern == 'spec'
        t.pattern = "#{kitchen_path}/spec/{" + properties[key][:roles].join(',') + '}/*_spec.rb'
      else
        t.pattern = "#{kitchen_path}/roles/{" + properties[key][:roles].join(',') + '}/spec/*_spec.rb'
      end
    end
  end
end
begin
  Rake::Task['spec'].invoke
rescue RuntimeError
  exit 1
end
