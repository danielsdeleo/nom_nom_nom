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

require 'yajl'
require 'nom_nom_nom/status'
require 'redis'
require 'singleton'

module NomNomNom
  module Server

    class DB

      module Connection

        def db
          DB.instance.connection
        end

      end

      include Singleton

      attr_reader :connection

      def initialize
        @connection = nil
        reset!
      end

      def reset!(connection_opts={})
        @connection.client.disconnect if @connection
        @connection = Redis.new(connection_opts)
      end

    end


    module StatusModel

      include DB::Connection

      module ClassMethods

        include DB::Connection

        def from_json(json)
          from_hash(Yajl::Parser.parse(json))
        end

        def list_nodes
          all_nodes = []
          failed_nodes.each { |n| all_nodes << [n, "failed"] }
          successful_nodes.each { |n| all_nodes << [n, "successful"]}
          all_nodes
        end

        def failed_nodes
          db.smembers("failed_nodes")
        end

        def successful_nodes
          db.sdiff("nodes", "failed_nodes")
        end

        def node?(node_name)
          db.sismember("nodes", node_name)
        end

        def node_history(node_name)
          statuses = db.lrange(node_name, 0, 10)
          Array(statuses).map { |s| from_hash(Yajl::Parser.parse(s)) }
        end

      end


      # DATA MODEL
      # set[nodes] => [node1, node2, ...]
      # set[failed_nodes] => [node1, node2, ...]
      # list[node_name] => [status1, status2, ...]

      def save
        db.sadd("nodes", node)
        db.lpush(node, Yajl::Encoder.encode(self.for_json))

        if success?
          db.srem("failed_nodes", node)
        else
          db.sadd("failed_nodes", node)
        end

        self
      end

    end
  end

  # Patch the Status class with model behaviors
  class Status
    include Server::StatusModel
    extend  Server::StatusModel::ClassMethods

  end

end
