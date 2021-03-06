module Bcome::WorkspaceCommands
  def ls(active_only = false)
    puts "\n\n" + visual_hierarchy.hierarchy + "\n"
    puts "\t" + "Available #{list_key}s:".title + "\n\n"

    iterate_over = active_only ? @resources.active : @resources

    if iterate_over.any?
      iterate_over.sort_by(&:identifier).each do |resource|
        is_active = @resources.is_active_resource?(resource)
        puts resource.pretty_description(is_active)
        puts "\n"
      end
    else
      puts "\tNo resources found".informational
    end

    new_line
    nil
  end

  def lsa
    show_active_only = true
    ls(show_active_only)
  end

  def interactive
    ::Bcome::Interactive::Session.run(self, :interactive_ssh)
  end

  def tree
    puts "\nTree view\n".title
    tab = ''
    parents.reverse.each do |p|
      print_tree_view_for_resource(tab, p)
      tab = "#{tab}\t"
    end
    print_tree_view_for_resource(tab, self)
    list_in_tree("#{tab}\t", resources)
    print "\n"
  end

  def parents
    ps = []
    ps << [parent, parent.parents] if has_parent?
    ps.flatten
  end

  def list_in_tree(tab, resources)
    resources.sort_by(&:identifier).each do |resource|
      next if resource.parent && !resource.parent.resources.is_active_resource?(resource)
      resource.load_nodes if resource.inventory? && !resource.nodes_loaded?
      print_tree_view_for_resource(tab, resource)
      list_in_tree("#{tab}\t", resource.resources)
    end
  end

  def print_tree_view_for_resource(tab, resource)
    separator = '-'
    tree_item = tab.to_s + separator.resource_key + " #{resource.type.resource_key} \s#{resource.identifier.resource_value}"
    tree_item += ' (empty set)' if !resource.server? && !resource.resources.has_active_nodes?
    puts tree_item
  end

  def cd(identifier)
    if resource = resources.for_identifier(identifier)
      if resource.parent.resources.is_active_resource?(resource)
        ::Bcome::Workspace.instance.set(current_context: self, context: resource)
      else
        puts "\nCannot enter context - #{identifier} is disabled. To enable enter 'enable #{identifier}'\n".error
      end
    else
      raise Bcome::Exception::InvalidBreadcrumb, "Cannot find a node named '#{identifier}'"
      puts "#{identifier} not found"
    end
  end

  def run(*raw_commands)
    raise Bcome::Exception::MethodInvocationRequiresParameter, "Please specify commands when invoking 'run'" if raw_commands.empty?
    results = {}

    ::Bcome::Ssh::ConnectionHandler.connect(self, {})

    machines.pmap do |machine|
      commands = machine.do_run(raw_commands)
      results[machine.namespace] = commands
    end
    results
  end

  def ping
    ::Bcome::Ssh::ConnectionHandler.connect(self, is_ping: true)
  end

  def pretty_description(is_active = true)
    desc = ''
    list_attributes.each do |key, value|
      next unless respond_to?(value) || instance_variable_defined?("@#{value}")
      attribute_value = send(value)
      next unless attribute_value

      desc += "\t"
      desc += is_active ? key.to_s.resource_key : key.to_s.resource_key_inactive
      desc += "\s" * (12 - key.length)
      desc += is_active ? attribute_value.resource_value : attribute_value.resource_value_inactive
      desc += "\n"
      desc = desc unless is_active
    end
    desc
  end

  def back
    exit
  end

  def disable(*ids)
    ids.each { |id| resources.do_disable(id) }
  end

  def enable(*ids)
    ids.each { |id| resources.do_enable(id) }
  end

  def clear!
    # Clear any disabled selection at this level and at all levels below
    resources.clear!
    resources.each(&:clear!)
    nil
  end

  def workon(*ids)
    resources.disable!
    ids.each { |id| resources.do_enable(id) }
    puts "\nYou are now working on '#{ids.join(', ')}\n".informational
  end

  def disable!
    resources.disable!
    resources.each(&:disable!)
    nil
  end

  def enable!
    resources.enable!
    resources.each(&:enable!)
    nil
  end

  ## Helpers --

  def resource_identifiers
    resources.collect(&:identifier)
  end

  def is_node_level_method?(method_sym)
    respond_to?(method_sym) || method_is_available_on_node?(method_sym)
  end

  def method_missing(method_sym, *arguments)
    unless method_is_available_on_node?(method_sym)
      raise NameError, "NameError: undefined local variable or method '#{method_sym}'"
    end

    if resource_identifiers.include?(method_sym.to_s)
      method_sym.to_s
    elsif instance_variable_defined?("@#{method_sym}")
      instance_variable_get("@#{method_sym}")
    else
      command = user_command_wrapper.command_for_console_command_name(method_sym)
      command.execute(self, arguments)
    end
  end

  def method_in_registry?(method_sym)
    ::Bcome::Registry::CommandList.instance.command_in_list?(self, method_sym)
  end

  def method_is_available_on_node?(method_sym)
    resource_identifiers.include?(method_sym.to_s) || instance_variable_defined?("@#{method_sym}") || method_in_registry?(method_sym) || respond_to?(method_sym)
  end

  def visual_hierarchy
    tabs = 0
    hierarchy = ''
    tree_descriptions.each { |d| hierarchy += "#{"\s\s\s" * tabs}|- #{d}\n"; tabs += 1; }
    hierarchy
  end

  def tree_descriptions
    d = parent ? parent.tree_descriptions + [description] : [description]
    d.flatten
  end

  def new_line
    puts "\n"
  end
end
