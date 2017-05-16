module Bcome::Node
  class Inventory < ::Bcome::Node::Base

    class << self
      def to_s
        "inventory"
      end
    end
 
    attr_reader :dynamic_nodes_loaded

    def initialize(*params)
      @dynamic_nodes_loaded = false
      super
      raise ::Bcome::Exception::InventoriesCannotHaveSubViews.new(@raw_view_data) if @raw_view_data[:views] && !@raw_view_data[:views].empty?
    end
 
    def list_key
      :server
    end

    def ls
      load_dynamic_nodes if no_nodes?
      super
    end

    def machines
      @resources.active
    end

    def reload!
      puts "\nReloading inventory...\n".bc_green
      load_dynamic_nodes
      puts "\nDone. Hit 'ls' to see the refreshed inventory.\n".bc_green
    end

    def override_server_identifier?
      !@override_identifier.nil?
    end

    def load_dynamic_nodes(silent = false)
      puts "Loading nodes for #{namespace}".bc_green unless silent
      raw_servers = fetch_server_list
      raw_servers.each {|raw_server|
        resources << ::Bcome::Node::Server.new_from_fog_instance(raw_server, self)
      }
      dynamic_nodes_loaded!
    end

    def dynamic_nodes_loaded!
      @dynamic_nodes_loaded = true
    end

    def has_dynamic_nodes?
      true
    end  

    def fetch_server_list
      network_driver.fetch_server_list(filters)
    end

  end
end
