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

require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

require 'time'
require 'nom_nom_nom/server/models/status_model'

describe NomNomNom::Status do

  describe "after it's saved in the database" do
    before do
      NomNomNom::Server::DB.instance.reset!(:db => 15)
      NomNomNom::Server::DB.instance.connection.flushall

      @status_data = {:all_resources     => ["package[sudo]", "execute[apt-get install]"],
                      :updated_resources => ["package[sudo]"],
                      :start_time        => Time.now.utc.iso8601,
                      :finish_time       => (Time.now + 42).utc.iso8601,
                      :cookbooks         => {"apt" => "1.2.3", "sudo" => "2.0.0"},
                      :node              => "server.example.com",
                      :recipes           => ["apt::default", "sudo::default"],
                      :roles             => ["base", "sudo"],
                      :success           => true,
                      :exception         => nil,
                      :exception_backtrace => nil }

      @status = NomNomNom::Status.new.consume_hash(@status_data)
      @status.save
    end

    it "shows up in the node list as a successful node" do
      NomNomNom::Status.list_nodes.should include(["server.example.com", "successful"])
    end

    it "saves its run history to the database" do
      history = NomNomNom::Status.node_history("server.example.com")
      history.should == [@status]
    end

    describe "and saved again" do
      before do
        @status.save
      end

      it "saves the second run to the history" do
        history = NomNomNom::Status.node_history("server.example.com")
        history.should have(2).statuses
        history.should == [@status, @status]
      end

    end

  end

end
