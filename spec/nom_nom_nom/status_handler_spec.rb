require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

require 'nom_nom_nom/status_handler'

require 'chef'
require 'chef/resource'
require 'chef/resource/package'
require 'chef/resource/template'
require 'chef/node'
require 'chef/cookbook_version'

describe StatusHandler do
  before do
    @status_handler = StatusHandler.new("http://example.org")
  end

  it "takes a status URL in the initializer" do
    @status_handler.status_url.should == "http://example.org"
  end

  describe "when the run status is set" do
    before do
      @node = Chef::Node.new
      @node.name("appserver.example.com")

      @run_context = Chef::RunContext.new(@node, {})
      @run_status = Chef::RunStatus.new(@node)

      # Has to go *after* RunContext.new or else chef tries to load recipes from
      # the server :(
      @node.run_list('recipe[sudo]', 'role[base]')
      @node.automatic_attrs.merge!("recipes" => ["sudo::default", "app::server", "hosts::default"], "roles" => ["base", "appserver"])

      @run_status.run_context = @run_context

      @start_time = Time.new
      @end_time = @start_time + 23
      Time.stub!(:now).and_return(@start_time, @end_time)

      @run_status.start_clock
      @run_status.stop_clock

      @sudo_pkg_resource = Chef::Resource::Package.new("sudo")
      @config_file_resource = Chef::Resource::Template.new("/etc/app/config.conf")

      @sudo_pkg_resource.updated_by_last_action(true)
      @run_context.resource_collection << @sudo_pkg_resource 
      @run_context.resource_collection << @config_file_resource

      @sudo_cookbook = Chef::CookbookVersion.new("sudo")
      @sudo_cookbook.version = "1.2.3"

      @app_cookbook = Chef::CookbookVersion.new("app")
      @app_cookbook.version = '4.2.0'

      @run_context.cookbook_collection['sudo'] = @sudo_cookbook
      @run_context.cookbook_collection['app']  = @app_cookbook

      @status_handler.instance_variable_set(:@run_status, @run_status)

      @nom_nom_status = @status_handler.status
    end

    it "generates the nom_nom_nom status from the Chef status" do
      @nom_nom_status.should == Status.from_run_status(@run_status)
    end
  end

end