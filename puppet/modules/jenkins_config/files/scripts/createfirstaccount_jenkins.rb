#!/usr/bin/ruby -w

# Copyright 2013 OpenStack Foundation.
# Copyright 2013 Hewlett-Packard Development Company, L.P.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#

require 'rubygems'
require 'nokogiri'

@check_exists = ARGV[0]
@config_file = '/var/lib/jenkins/config.xml'
@path_users = '/var/lib/jenkins/users'
@user_names = Array.new
@permissions = Array [
  'com.cloudbees.plugins.credentials.CredentialsProvider.Create:@user',
  'com.cloudbees.plugins.credentials.CredentialsProvider.Delete:@user',
  'com.cloudbees.plugins.credentials.CredentialsProvider.ManageDomains:@user',
  'com.cloudbees.plugins.credentials.CredentialsProvider.Update:@user',
  'com.cloudbees.plugins.credentials.CredentialsProvider.View:@user',
  'hudson.model.Computer.Build:@user',
  'hudson.model.Computer.Configure:@user',
  'hudson.model.Computer.Connect:@user',
  'hudson.model.Computer.Create:@user',
  'hudson.model.Computer.Delete:@user',
  'hudson.model.Computer.Disconnect:@user',
  'hudson.model.Hudson.Administer:@user',
  'hudson.model.Hudson.ConfigureUpdateCenter:@user',
  'hudson.model.Hudson.Read:@user',
  'hudson.model.Hudson.RunScripts:@user',
  'hudson.model.Hudson.UploadPlugins:@user',
  'hudson.model.Item.Build:@user',
  'hudson.model.Item.Cancel:@user',
  'hudson.model.Item.Configure:@user',
  'hudson.model.Item.Create:@user',
  'hudson.model.Item.Delete:@user',
  'hudson.model.Item.Discover:@user',
  'hudson.model.Item.ExtendedRead:@user',
  'hudson.model.Item.Read:@user',
  'hudson.model.Item.Workspace:@user',
  'hudson.model.Run.Delete:@user',
  'hudson.model.Run.Update:@user',
  'hudson.model.View.Configure:@user',
  'hudson.model.View.Create:@user',
  'hudson.model.View.Delete:@user',
  'hudson.model.View.Read:@user',
  'hudson.scm.SCM.Tag:@user',
  'com.cloudbees.plugins.credentials.CredentialsProvider.View:anonymous',
  'com.cloudbees.plugins.credentials.CredentialsProvider.View:authenticated',
  'hudson.model.Hudson.Read:anonymous',
  'hudson.model.Hudson.Read:authenticated',
  'hudson.model.Item.ExtendedRead:anonymous',
  'hudson.model.Item.ExtendedRead:authenticated',
  'hudson.model.Item.Read:anonymous',
  'hudson.model.Item.Read:authenticated',
  'hudson.model.View.Read:anonymous',
  'hudson.model.View.Read:authenticated',
  'hudson.model.Item.Build:gerrig',
  'hudson.model.Item.Cancel:gerrig',
  'hudson.model.Item.Configure:gerrig',
  'hudson.model.Item.Create:gerrig',
  'hudson.model.Item.Delete:gerrig',
  'hudson.model.Item.Discover:gerrig',
  'hudson.model.Item.ExtendedRead:gerrig',
  'hudson.model.Item.Read:gerrig',
  'hudson.model.Item.Workspace:gerrig',
  'hudson.model.Hudson.Read:gerrig'
]

if @check_exists == 'validate'
  if File.exists?(@config_file)
    @doc = Nokogiri::XML(File.open(@config_file)) do |config|
      config.default_xml.noblanks
    end
    authorization_strategy = @doc.at('authorizationStrategy')
    if authorization_strategy.children().count != 20
      puts "The Config.file was already updated"
      exit 1
    else
      exit 0
    end
  else
    puts "Config.xml file not found."
    exit 1
  end
end

if File.directory? @path_users
  ################### Get first user name registered in jenkins.###################
  @user_names = Dir.entries(@path_users).select {|entry| !(entry =='.' || entry == '..' || entry == 'anonymous' || entry == 'gerrig' || entry == 'authenticated') }
  if @user_names.count > 0
    ################### Open and add the permission elements into the xml.###################
    @doc = Nokogiri::XML(File.open(@config_file)) do |config|
      config.default_xml.noblanks
    end
    authorization_strategy = @doc.at('authorizationStrategy')
    authorization_strategy['class'] = 'hudson.security.GlobalMatrixAuthorizationStrategy'

    ################### For each user registered, add them as administrator. only one time.###################
    for user in (@user_names)
      for permission in @permissions
        permission.sub! '@user', user

        ################### Create the new permissions XML Node.###################
        node_permission = Nokogiri::XML::Node.new 'permission', @doc
        node_permission.content = permission
        exists = false

        ################### Validate if the Permissions XML node already exists.###################
        for child in authorization_strategy.children()
          if child.content == node_permission.content
            exists = true
          end
        end

        ################### If the node didn't exists, then add the node to the XML
        if exists == false
          authorization_strategy.add_child(node_permission)
        end
      end
    end

    ################### Save the XML file.###################
    File.open(@config_file, 'w') {|f| f.puts @doc.to_xml }
    puts 'Successfully'
    system 'sudo service jenkins restart'
    exit 0
  else
    puts 'there are not registered users yet in jenkins'
    exit 0
  end
else
  puts 'there are not registered users yet in jenkins'
  exit 0
end
