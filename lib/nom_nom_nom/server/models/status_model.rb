require 'yajl'
require 'nom_nom_nom/status'
require 'redis'

module NomNomNom
  module Server
    module StatusModel

      module Connection

        # this is probably nieve and terrible, but it works for now
        def redis
          r = Redis.new
          yield r
        ensure
          r.client.disconnect
        end

      end

      include Connection

      module ClassMethods

        include Connection

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
          redis { |r| r.smembers("failed_nodes") }
        end

        def successful_nodes
          redis { |r| r.sdiff("nodes", "failed_nodes") }
        end

        def node?(node_name)
          redis { |r| r.sismember("nodes", node_name) }
        end

        def node_history(node_name)
          redis { |r| r.lrange(node_name, 0, 10) }
        end

      end


      # DATA MODEL
      # set[nodes] => [node1, node2, ...]
      # set[failed_nodes] => [node1, node2, ...]
      # list[node_name] => [status1, status2, ...]

      def save
        redis do |r|
          r.sadd("nodes", node)

          if success?
            r.del("failed_nodes", node)
          else
            r.sadd("failed_nodes", node)
          end

          r.lpush(node, Yajl::Encoder.encode(self.for_json))
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
