require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

require 'chef'
require 'chef/run_context'
require 'chef/run_status'
require 'chef/resource'
require 'chef/node'
require 'chef/cookbook_version'

require 'nom_nom_nom/status'

describe NomNomNom::Status do
  before do
    
  end

  describe "when created from a run status" do
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

      @status = NomNomNom::Status.from_run_status(@run_status)
    end

    it "collects a map of all resources and their text representations" do
      @status.all_resources.should == {'package[sudo]' => @sudo_pkg_resource.to_text,
                                      'template[/etc/app/config.conf]' => @config_file_resource.to_text}
    end

    it "collects a map of updated resources and their text representations" do
      @status.updated_resources.should == {'package[sudo]' => @sudo_pkg_resource.to_text}
    end

    it "extracts the start time from the run status" do
      @status.start_time.should == @start_time.utc.iso8601
    end

    it "extracts the end time from the run status" do
      @status.finish_time.should == @end_time.utc.iso8601
    end

    it "extracts the list of cookbook names and versions from the run status' run context" do
      @status.cookbooks.should == {"sudo" => '1.2.3', "app" => '4.2.0'}
    end

    it "collects the node name" do
      @status.node.should == "appserver.example.com"
    end

    it "collects the expanded recipe list and expanded role list" do
      @status.recipes.should == ["sudo::default", "app::server", "hosts::default"]
      @status.roles.should   == ["base", "appserver"]
    end

    describe "and the run was successful" do
      it "marks the status as success" do
        @status.should be_success
      end
    end

    describe "and the run failed with an exception" do
      before do
        @backtrace = caller
        @exception = RuntimeError.new("failed to do the thing")
        @exception.set_backtrace(@backtrace)
        @run_status.exception = @exception

        @status = NomNomNom::Status.from_run_status(@run_status)
      end

      it "marks the status as failed" do
        @status.should_not be_success
      end

      it "collects the backtrace and exception message" do
        @status.exception.should == "RuntimeError: failed to do the thing"
        @status.backtrace.should == @backtrace
      end
    end

    describe "when converted to a Hash" do
      before do
        @status_hash = @status.to_hash
      end

      it "has the list of all resources" do
        @status_hash[:all_resources].should == @status.all_resources
      end

      it "has the list of updated resources" do
        @status_hash[:updated_resources].should == @status.updated_resources
      end

      it "has the start and stop time" do
        @status_hash[:start_time].should == @start_time.utc.iso8601
        @status_hash[:finish_time].should == @end_time.utc.iso8601
      end

      it "has the list of cookbooks and versions" do
        @status_hash[:cookbooks].should == {"sudo" => '1.2.3', "app" => '4.2.0'}
      end

      it "has the node name" do
        @status_hash[:node].should == "appserver.example.com"
      end

      it "has the applied recipes and roles" do
        @status_hash[:recipes].should == ["sudo::default", "app::server", "hosts::default"]
        @status_hash[:roles].should   == ["base", "appserver"]
      end

      it "has the success/failure status" do
        @status_hash[:success].should be_true
      end
    end

    describe "when loading from a hash" do
      it "does something" do
        NomNomNom::Status.from_hash(@status.to_hash).should == @status
      end
    end

  end

end