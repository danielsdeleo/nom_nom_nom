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