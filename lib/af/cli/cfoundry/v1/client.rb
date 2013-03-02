module CFoundry::V1
  class Client
    attr_reader :base

    # Retrieve available infras.
    def info_infras
      @base.get("info", "infras", :accept => :json)
    end

    def infras(options = {})
      ins = info_infras
      return unless ins

      infras = []
      ins.each do |inf|
        infras <<
          Infra.new(inf[:infra], inf[:name], inf[:description], inf[:base], inf[:locality], inf[:vendor])
      end

      infras
    end

    def infra(name)
      infra_by_name(name) || Infra.new(name)
    end

    def infra_by_name(name)
      infras.find { |i| i.name == name }
    end

    # Added to support downloads
    def app_download(name, path)
      body = @base.get("apps", name, "application")
      file = File.new(path, "wb")
      file.write(body)
      file.close
    end

    # Added to support app pulls
    def app_pull(name, dir)
      body = @base.get("apps", name, "application")
      file = Tempfile.new(name)
      file.binmode
      file.write(body)
      file.close
      CFoundry::Zip.unpack(file.path, dir)
      file.unlink
    end

    # Retrieve available services.
    def services(options = {})
      services = []

      @base.system_services.each do |infra, infra_services|
        infra_services.each do |type, vendors|
          vendors.each do |vendor, providers|
            providers.each do |provider, properties|
              properties.each do |_, meta|
                meta[:supported_versions].each do |ver|
                  state = meta[:version_aliases].find { |k, v| v == ver }

                  services <<
                    Service.new(vendor.to_s, infra, ver.to_s, meta[:description],
                                type.to_s, provider.to_s, state && state.first,
                                meta[:plans], meta[:default_plan])
                end
              end
            end
          end
        end
      end

      services
    end

    def export_service(service_name)
      @base.get("services", "export", service_name, :accept => :json)
    end

    def import_service(service_name, uri)
      @base.post("services", "import", service_name, :payload => {:uri => uri}, :multipart => true, :accept => '*/*; q=0.5, application/xml')
    end
  end
end
