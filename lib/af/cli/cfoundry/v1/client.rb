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
  end
end
