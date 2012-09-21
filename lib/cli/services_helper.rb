
module VMC::Cli
  module ServicesHelper
    def display_system_services(services=nil)
      services ||= client.services_info

      display "\n============== System Services ==============\n\n"

      return display "No system services available" if services.empty?

      displayed_services = []
      services.each do |service_type, value|
        value.each do |vendor, version|
          version.each do |version_str, service|
            displayed_services << [ vendor, version_str, service[:description] ]
          end
        end
      end
      displayed_services.sort! { |a, b| a.first.to_s <=> b.first.to_s}

      services_table = table do |t|
        t.headings = 'Service', 'Version', 'Description'
        displayed_services.each { |s| t << s }
      end
      display services_table
    end

    def display_provisioned_services(services=nil)
      services ||= client.services
      display "\n=========== Provisioned Services ============\n\n"
      display_provisioned_services_table(services)
    end

    def display_provisioned_services_table(services)
      return unless services && !services.empty?
      
      infra_supported = !services.detect { |a| a[:infra] }.nil?
      services_table = table do |t|
        t.headings = 'Name', 'Service'
        t.headings << 'In' if infra_supported
        services.each do |service|
          s =  [ service[:name], service[:vendor] ]
          if infra_supported
            s << ( service[:infra] ? service[:infra][:provider] : "   " )
          end
          t << s
        end
      end
      display services_table
    end

    def create_service_banner(service, name, display_name=false, infra=nil)
      sn = " [#{name}]" if display_name
      display "Creating Service#{sn}: ", false
      client.create_service(infra,service, name)
      display 'OK'.green
    end

    def bind_service_banner(service, appname, check_restart=true)
      display "Binding Service [#{service}]: ", false
      client.bind_service(service, appname)
      display 'OK'.green
      check_app_for_restart(appname) if check_restart
    end

    def unbind_service_banner(service, appname, check_restart=true)
      display "Unbinding Service [#{service}]: ", false
      client.unbind_service(service, appname)
      display 'OK'.green
      check_app_for_restart(appname) if check_restart
    end

    def delete_service_banner(service)
      display "Deleting service [#{service}]: ", false
      client.delete_service(service)
      display 'OK'.green
    end

    def random_service_name(service)
      r = "%04x" % [rand(0x0100000)]
      "#{service.to_s}-#{r}"
    end
    
    def generate_cloned_service_name(src_appname,dest_appname,src_servicename,dest_infra)
      r = "%04x" % [rand(0x0100000)]
      dest_servicename = src_servicename.sub(src_appname,dest_appname).sub(/-[0-9A-Fa-f]{4,5}/,"-#{r}")
      if src_servicename == dest_servicename
        if dest_infra
          dest_servicename = "#{dest_servicename}-#{dest_infra}"
        else
          dest_servicename = "#{dest_servicename}-#{r}"
        end
      end
      dest_servicename
    end

    def check_app_for_restart(appname)
      app = client.app_info(appname)
      cmd = VMC::Cli::Command::Apps.new(@options)
      cmd.restart(appname) if app[:state] == 'STARTED'
    end

  end
end
