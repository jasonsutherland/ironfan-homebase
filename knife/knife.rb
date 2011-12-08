# -*- coding: utf-8 -*-
organization = ENV['CHEF_ORGANIZATION']
username     = ENV['CHEF_USER']
homebase_dir = ENV['CHEF_HOMEBASE']
knife_dir    = File.dirname(__FILE__)

raise('please set the CHEF_ORGANIZATION, CHEF_USER environment variables to your chef server organization and username, and CHEF_HOMEBASE to the base directory for your cookbooks') unless organization && username && homebase_dir

$LOAD_PATH.unshift "#{homebase_dir}/vendor/cluster_chef/lib"
require 'cluster_chef'

# Path to your clusters, cookbooks and roles
cluster_path             [ "#{homebase_dir}/clusters"  ]
cookbook_path            [ "#{homebase_dir}/cookbooks" ]
role_path                [ "#{homebase_dir}/roles"     ]

# Cloud keypairs -- be sure to `chmod og-rwx -R */*-keys/`
client_key_dir          "#{knife_dir}/#{organization}/client_keys"
ec2_key_dir             "#{knife_dir}/#{organization}/ec2_keys"

log_level                :info
log_location             STDOUT
node_name                username
chef_server_url          "https://api.opscode.com/organizations/#{organization}"
validation_client_name   "#{organization}-validator"
validation_key           "#{knife_dir}/#{organization}/#{organization}-validator.pem"
client_key               "#{knife_dir}/#{organization}/#{username}.pem"
cache_type               'BasicFile'
cache_options            :path => "#{knife_dir}/checksums"

# If you primarily use AWS cloud services:
knife[:ssh_address_attribute] = 'cloud.public_hostname'
knife[:ssh_user]              = 'ubuntu'

# Configure bootstrapping
knife[:bootstrap_runs_chef_client] = true
bootstrap_chef_version   "~> 0.10.4"

def load_if_exists(file) ; load(file) if File.exists?(file) ; end

# Access credentials
load_if_exists "#{knife_dir}/#{organization}/credentials.rb"
# Organization-sepecific settings -- Chef::Config[:ec2_image_info] and so forth
load_if_exists "#{knife_dir}/#{organization}/cloud.rb"
# User-specific knife info or credentials
load_if_exists "#{knife_dir}/knife-user-#{user}.rb"
