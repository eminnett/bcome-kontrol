module Bcome::WorkspaceMenu

  def menu
    print "\n\n"
    puts "#{mode} menu".title + "\sfor #{self.class} #{self.namespace}".resource_value + "\n\n"
    enabled_menu_items.each_with_index do |menu_item, index|
      item = menu_items[menu_item]
      next if !::Bcome::System::Local.instance.in_console_session? && item[:console_only]
      puts tab_spacing + "#{menu_item}".resource_key + item_spacing(menu_item) + "#{menu_items[menu_item][:description]}".resource_value
      if (item[:usage] || item[:terminal_usage])
        usage_string = ::Bcome::System::Local.instance.in_console_session? ? item[:usage] : item[:terminal_usage]
        puts tab_spacing + ("\s" * menu_item_spacing_length) + "usage: ".instructional + usage_string
      end
      puts "\n"
    end

    return
  end  

  def mode
    ::Bcome::System::Local.instance.in_console_session? ? "Console" : "Terminal"
  end

  def item_spacing(item)
    "\s" * (menu_item_spacing_length - item.length)
  end

  def menu_item_spacing_length
    14
  end  

  def tab_spacing
    "\s" * 3
  end 

  def menu_items
    {
      ls: {
        description: "list all available resources",
        console_only: false
      },
      lsa: {
        description: "list all active resources",
        console_only: true
      },
      workon: {
        description: "work on specific resources only, inactivating all others from this selection",
        usage: "workon identifier1, identifier2 ...",
        console_only: true
      },
      disable: {
        description: "remove a resource from this selection",
        usage: "disable identifier1, identifier2 ...",
        console_only: true
      },
      enable: {
        description: "re-enable a resource within this selection",
        usage: "enable identifier1, identifier2 ...",
        console_only: true
      },
      enable!: {
        description: "enable all resources within this selection",
        console_only: true
      },
      disable!: {
        description: "disable all resources within this selection",
        console_only: true
      },
      run: {
        description: "execute a command to be run over ssh against all active resources",
        usage: "run 'command1', 'command2', ...",
        console_only: false,
        terminal_usage: "run 'command1' 'command2' ..."
      },
      interactive: {
        description: "enter an interactive command session for all active resources",
        console_only: false
      },
      tree: {
        description: "print a tree view for all resources and their sub-resources",
        console_only: false
      },
      ping: {
        description: "ping all resources to test connectivity",
        console_only: false
      },
      put: {
        description: "upload a file",
        usage: "put 'local/path','remote/path'",
        console_only: false,
        terminal_usage: "put 'local/path' 'remote/path'"
      },
      get: {
        description: "download a file",
        usage: "get 'remote/path', 'local/path'",
        console_only: false,
        terminal_usage: "get 'remote/path' 'local/path"
      },
      cd: {
        description: "enter the namespace for a resource from this selection",
        usage: "cd identifier",
        console_only: true
      },
      save: {
        description: "Save the current tree state",
        console_only: true
      },
      reload: {
        description: "Restock this inventory from remote (hit 'save' after to persist)",
        console_only: true
      },
      meta: {
        description: "Print out all metadata related to this node"
      },
      registry: {
        description: "List all user defined commands present in your registry, and available to this namespace",
        :console_only => false
      }
    }
  end

end
