module Bcome::Node
  class Inventory < ::Bcome::Node::Base

    def self.to_s
      'inventory'
    end

    attr_reader :dynamic_nodes_loaded

    def initialize(*params)
      @dynamic_nodes_loaded = false
      super
      set_static_servers
      load_dynamic_nodes
      raise Bcome::Exception::InventoriesCannotHaveSubViews, @raw_view_data if @raw_view_data[:views] && !@raw_view_data[:views].empty?
    end

    def set_static_servers
      if server_configs = @raw_view_data[:static_servers]
        server_configs.each {|server_config|
          resources << ::Bcome::Node::Server::Static.new(view_data: server_config, parent: self)
        }
      end
    end

    def resources
      @resources ||= ::Bcome::Node::Resources::Inventory.new
    end

    def list_key
      :server
    end

    def machines
      @resources.active
    end

    def reload!
      load_dynamic_nodes
      puts "\nDone. Hit 'ls' to see the refreshed inventory.\n".bc_green
    end

    def override_server_identifier?
      !@override_identifier.nil?
    end

    def load_dynamic_nodes(silent = false)
      puts "Loading dynamic inventory for #{self.namespace}"
      raw_servers = fetch_server_list
      raw_servers.each do |raw_server|
        resources << ::Bcome::Node::Server::Dynamic.new_from_fog_instance(raw_server, self)
      end
      dynamic_nodes_loaded!
    end

    def dynamic_nodes_loaded!
      @dynamic_nodes_loaded = true
    end

    def has_dynamic_nodes?
      true
    end

    def fetch_server_list
      return [] unless network_driver
      network_driver.fetch_server_list(filters)
    end
  end
end
