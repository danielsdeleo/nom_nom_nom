require 'yajl'
require 'nom_nom_nom/server/models/status_model'

module NomNomNom
  module Server
    class Application < Sinatra::Base

      ROOT = File.expand_path(File.dirname(__FILE__))

      register Mustache::Sinatra

      set :mustache, {:templates => ROOT + '/templates',
                      :views => ROOT + "/views",
                      :namespace => NomNomNom::Server,
                      :layout => true}

      set :public, ROOT + '/public'

      ###
      # HTML/UI
      ###

      get "/" do
        #"Nom Nom Nom"
        mustache :home
      end


      ###
      # JSON/API
      ###

      get  "/api/nodes" do
        statuses = NomNomNom::Status.list_nodes
        Yajl::Encoder.encode(statuses)
      end

      get  "/api/nodes/failed" do
        statuses = NomNomNom::Status.failed_nodes
        Yajl::Encoder.encode(statuses)
      end

      get  "/api/nodes/successful" do
        statuses = NomNomNom::Status.successful_nodes
        Yajl::Encoder.encode(statuses)
      end

      get  "/api/nodes/:node_name" do |node_name|
        unless NomNomNom::Status.node?(node_name)
          halt(404, Yajl::Encoder.encode({:reason => "node #{node_name} not found"}))
        end

        statuses = NomNomNom::Status.node_history(node_name)
        Yajl::Encoder.encode(statuses)
      end

      post "/api/statuses" do
        status = NomNomNom::Status.from_json(request.body)
        status.save
      end

    end
  end
end
