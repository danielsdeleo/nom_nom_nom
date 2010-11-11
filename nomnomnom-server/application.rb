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

        statuses = NomNomNom::Status.node_history(node_name).map { |n| n.for_json }
        Yajl::Encoder.encode(statuses)
      end

      post "/api/statuses" do
        status = NomNomNom::Status.from_json(request.body)
        status.save
      end

    end
  end
end
