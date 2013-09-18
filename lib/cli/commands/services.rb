require "uuidtools"

module VMC::Cli::Command

  class Services < Base
    include VMC::Cli::ServicesHelper
    include VMC::Cli::TunnelHelper

    def services
      ss = client.services_info
      ps = client.services
      ps.sort! {|a, b| a[:name] <=> b[:name] }

      if @options[:json]
        services = { :system => ss, :provisioned => ps }
        return display JSON.pretty_generate(services)
      end
      display_system_services(ss)
      display_provisioned_services(ps)
    end

    def create_service(service=nil, name=nil, appname=nil)

      unless no_prompt || service
        services = client.services_info
        err 'No services available to provision' if services.empty?
        service = ask(
          "Which service would you like to provision?",
          { :indexed => true,
            :choices =>
              services.values.collect { |type|
                type.keys.collect(&:to_s)
              }.flatten
          }
        )
      end
      name = @options[:name] unless name
      unless name
        name = random_service_name(service)
        picked_name = true
      end

      if client.infra_supported?
        unless no_prompt || @options[:infra]
          @options[:infra] = client.infra_name_for_description(
              ask("Select Infrastructure",
                :indexed => true, :choices => client.infra_descriptions))
        end
      end

      create_service_banner(service, name, picked_name, @options[:infra])
      appname = @options[:bind] unless appname
      bind_service_banner(name, appname) if appname
    end

    def delete_service(service=nil)
      unless no_prompt || service
        user_services = client.services
        err 'No services available to delete' if user_services.empty?
        service = ask(
          "Which service would you like to delete?",
          { :indexed => true,
            :choices => user_services.collect { |s| s[:name] }
          }
        )
      end
      err "Service name required." unless service
      display "Deleting service [#{service}]: ", false
      client.delete_service(service)
      display 'OK'.green
    end

    def bind_service(service, appname)
      bind_service_banner(service, appname)
    end

    def unbind_service(service, appname)
      unbind_service_banner(service, appname)
    end

    def clone_services(src_app, dest_app)
      begin
        src  = client.app_info(src_app)
        dest = client.app_info(dest_app)
      rescue
      end

      err "Application '#{src_app}' does not exist" unless src
      err "Application '#{dest_app}' does not exist" unless dest

      services = src[:services]
      err 'No services to clone' unless services && !services.empty?
      services.each { |service| bind_service_banner(service, dest_app, false) }
      check_app_for_restart(dest_app)
    end

    def export_service(service)
      display "Exporting data from '#{service}': ", false
      export_info = client.export_service(service)
      if export_info
        display 'OK'.green
        puts export_info[:uri]
      else
        err "Export data from '#{service}': failed"
      end
    end

    def import_service(service,url)
      display "Importing data into '#{service}': ", false
      import_info = client.import_service(service,url)
      if import_info
        display 'OK'.green
      else
        err "Import data into '#{service}' failed"
      end
    end

    def tunnel(service=nil, client_name=nil)
      unless defined? Caldecott
        display "To use `af tunnel', you must first install Caldecott:"
        display ""
        display "\tgem install caldecott"
        display ""
        display "Note that you'll need a C compiler. If you're on OS X, Xcode"
        display "will provide one. If you're on Windows, try DevKit."
        display ""
        display "This manual step will be removed in the future."
        display ""
        err "Caldecott is not installed."
      end

      ps = client.services
      err "No services available to tunnel to" if ps.empty?

      unless service
        choices = ps.collect { |s| s[:name] }.sort
        service = ask(
          "Which service to tunnel to?",
          :choices => choices,
          :indexed => true
        )
      end

      info = ps.select { |s| s[:name] == service }.first

      err "Unknown service '#{service}'" unless info

      port = pick_tunnel_port(@options[:port] || 10000)

      raise VMC::Client::AuthError unless client.logged_in?

      infra_name = nil
      if client.infra_supported?
        infra_name = info[:infra] ? info[:infra][:name] : default_infra
        err "Infra '#{infra_name}' is not valid" unless client.infra_valid?(infra_name)
      end

      if not tunnel_pushed?(infra_name)
        display "Deploying tunnel application '#{tunnel_appname(infra_name)}'."
        auth = UUIDTools::UUID.random_create.to_s
        push_caldecott(auth,infra_name)
        bind_service_banner(service, tunnel_appname(infra_name), false)
        start_caldecott(infra_name)
      else
        auth = tunnel_auth(infra_name)
      end

      if not tunnel_healthy?(auth,infra_name)
        display "Redeploying tunnel application '#{tunnel_appname(infra_name)}'."

        # We don't expect caldecott not to be running, so take the
        # most aggressive restart method.. delete/re-push
        client.delete_app(tunnel_appname(infra_name))
        invalidate_tunnel_app_info(infra_name)

        push_caldecott(auth,infra_name)
        bind_service_banner(service, tunnel_appname(infra_name), false)
        start_caldecott(infra_name)
      end

      if not tunnel_bound?(service,infra_name)
        bind_service_banner(service, tunnel_appname(infra_name))
      end

      conn_info = tunnel_connection_info info[:vendor], service, auth, infra_name
      display_tunnel_connection_info(conn_info)
      display "Starting tunnel to #{service.bold} on port #{port.to_s.bold}."
      start_tunnel(port, conn_info, auth, infra_name)

      clients = get_clients_for(info[:vendor])

      if clients.empty?
        client_name ||= "none"
      else
        client_name ||= ask(
          "Which client would you like to start?",
          :choices => ["none"] + clients.keys,
          :indexed => true
        )
      end

      if client_name == "none"
        wait_for_tunnel_end
      else
        wait_for_tunnel_start(port)
        unless start_local_prog(clients, client_name, conn_info, port)
          err "'#{client_name}' execution failed; is it in your $PATH?"
        end
      end
    end

    def get_clients_for(type)
      conf = VMC::Cli::Config.clients
      conf[type] || {}
    end
  end
end
