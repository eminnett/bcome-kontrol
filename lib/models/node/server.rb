module Bcome::Node
  class Server < Bcome::Node::Base
    class << self
      def new_from_fog_instance(fog_instance, parent)
        identifier = fog_instance.tags['Name']

        if parent.override_server_identifier?
          identifier =~ /#{parent.override_identifier}/
          identifier = Regexp.last_match(1) if Regexp.last_match(1)
        end

        params = {
          identifier: identifier,
          internal_interface_address: fog_instance.private_ip_address,
          public_ip_address: fog_instance.public_ip_address,
          role: fog_instance.tags['function'],
          description: "EC2 server - #{identifier}",
          type: 'server',
          ec2_server: fog_instance
        }

        new(parent: parent,
            view_data: params)
      end
    end

    def ls
      puts "\n" + visual_hierarchy.orange + "\n"
      puts pretty_description

      if ::Bcome::System::Local.instance.in_console_session?
        puts "\s\s\n\tType '?' to see your options\n\n".green
      else
        puts "\n\n"
      end
    end

    def ssh
      ssh_driver.do_ssh
    end 

    def list_attributes
      {
        "identifier": :identifier,
        "internal ip": :internal_interface_address,
        "public ip": :public_ip_address,
      }
    end
  end
end
