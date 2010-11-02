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

require 'restclient'
require 'yajl'
require 'chef/handler'
require 'chef/run_status'

require 'nom_nom_nom/status'

module NomNomNom
  class StatusHandler < Chef::Handler

    attr_reader :status_url

    def initialize(status_url)
      @status_url = status_url
    end

    def status
      NomNomNom::Status.from_run_status(run_status)
    end

    def post_body
      Yajl::Encoder.encode(status.to_hash)
    end

    def report
      RestClient.post(status_url, post_body, :content_type => :json, :accept => :json)
    end
  end
end