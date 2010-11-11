#--
# Author:: Daniel DeLeo (<dan@opscode.com>)
# Copyright:: Copyright (c) 2010 Opscode, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'time'

module NomNomNom
  class Status

    # create a Status from a Chef::RunStatus
    def self.from_run_status(run_status)
      s = new
      s.consume_run_status(run_status)
      s
    end

    def self.from_hash(status_hash)
      s = new
      s.consume_hash(status_hash)
      s
    end

    attr_reader :all_resources

    attr_reader :updated_resources

    attr_reader :start_time

    attr_reader :finish_time

    attr_reader :cookbooks

    attr_reader :node

    attr_reader :recipes

    attr_reader :roles

    attr_reader :exception

    attr_reader :backtrace

    def initialize
      @cookbooks         = {}
      @updated_resources = {}
      @all_resources     = {}
      @start_time = nil
      @finish_time = nil
      @node = nil
      @recipes = []
      @roles   = []
      @exception = nil
      @backtrace = []
    end

    def consume_run_status(run_status)
      extract_resources(run_status)
      extract_timing(run_status)
      extract_cookbook_names_and_versions(run_status)
      extract_node_info(run_status)
      extract_exception(run_status)
    end

    def to_hash
      { :all_resources     => all_resources,
        :updated_resources => updated_resources,
        :start_time        => start_time,
        :finish_time       => finish_time,
        :cookbooks         => cookbooks,
        :node              => node,
        :recipes           => recipes,
        :roles             => roles,
        :success           => success?,
        :exception         => (exception),
        :exception_backtrace => backtrace }
    end

    alias :for_json :to_hash

    def consume_hash(hash)
      hash = stringify_hash_keys(hash)

      @all_resources     = hash['all_resources']
      @updated_resources = hash['updated_resources']
      @start_time        = hash['start_time']
      @finish_time       = hash['finish_time']
      @cookbooks         = hash['cookbooks']
      @node              = hash['node']
      @recipes           = hash['recipes']
      @roles             = hash['roles']

      @exception         = hash["exception"]
      @backtrace         = hash["exception_backtrace"]

      self
    end

    def success?
      !@exception
    end

    def ==(other)
      other.kind_of?(NomNomNom::Status) && other.to_hash == to_hash
    end

    private

    def stringify_hash_keys(hash)
      stringified = {}
      hash.each do |key, value|
        stringified[key.to_s] = value
      end
      stringified
    end

    def extract_resources(run_status)
      if run_status.all_resources.respond_to?(:each)
        run_status.all_resources.each do |resource|
          @all_resources[resource.to_s]     = resource.to_text
          @updated_resources[resource.to_s] = resource.to_text if resource.updated?
        end
      end
    end

    def extract_timing(run_status)
      @start_time   = run_status.start_time.utc.iso8601
      @finish_time  = run_status.end_time.utc.iso8601
    end

    def extract_cookbook_names_and_versions(run_status)
      if run_status.run_context.respond_to?(:cookbook_collection) && run_status.run_context.cookbook_collection.respond_to?(:each)
        run_status.run_context.cookbook_collection.each do |cookbook_name, cookbook_info|
          @cookbooks[cookbook_name] = cookbook_info.version if cookbook_info.respond_to?(:version)
        end
      end
    end

    def extract_node_info(run_status)
      @node = run_status.node.name
      @recipes = run_status.node['recipes']
      @roles   = run_status.node['roles']
    end

    def extract_exception(run_status)
      @exception = run_status.formatted_exception
      @backtrace = run_status.backtrace
    end

  end
end