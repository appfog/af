module CFoundry::V1
  class Client
    include ClientMethods, CFoundry::LoginHelpers
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
  end
end

module CFoundry::V1
  class Infra
    attr_accessor :name
    attr_accessor :infra
    attr_accessor :description
    attr_accessor :base
    attr_accessor :locality
    attr_accessor :vendor

    def initialize(name, infra = nil, description = nil, base = nil, locality = nil, vendor = nil)
      @name = name
      @infra = infra
      @description = description
      @locality = locality
      @vendor = vendor
      @base = base
    end

    def eql?(other)
      other.is_a?(self.class) && other.name == @nameidp
    end
    alias :== :eql?

    def apps
      [] # not supported by v1
    end
  end
end

# Patched to support infra
module CFoundry::V1
  class App
    attribute :infra, :string, :at => [:infra, :provider], :default => 'aws'

    alias_method :infra_name, :infra
    alias_method :infra_name=, :infra=

    def infra
      @client.infra(infra_name)
    end

    def infra=(obj)
      set_named(:infra, obj)
    end

    def inspect
      "\#<#{self.class.name} '#@guid'>"
    end

    # remap payload locations
    write_locations[:framework] = [:staging, :framework]
    write_locations[:runtime] = [:staging, :runtime]
  end
end

# Patched to support infra
module CFoundry::V1
  class ServiceInstance
    attribute :infra, :string, :at => [:infra, :provider], :default => 'aws'

    alias_method :infra_name, :infra
    alias_method :infra_name=, :infra=

    def infra
      @client.infra(infra_name)
    end

    def infra=(obj)
      set_named(:infra, obj)
    end
  end
end

# Patched to support legacy api proxy
module CFoundry::V1
  class Base < CFoundry::BaseClient
    def upload_app(name, zipfile, resources = [])
      payload = {
        :_method => "put",
        :application =>
          UploadIO.new(
            if zipfile.is_a? File
              zipfile
            elsif zipfile.is_a? String
              File.new(zipfile, "rb")
            end,
            "application/zip"),
        :resources => MultiJson.dump(resources)
      }
      # Accept type overrided for compatibility with old api proxy, should just be '*/*'
      post("apps", name, "application", :payload => payload, :multipart => true, :accept => '*/*; q=0.5, application/xml')
    rescue EOFError
      retry
    end
  end
end

# Patched to support .afignore
module CFoundry
  module UploadHelpers
    def prepare_package(path, to)
      if path =~ /\.(jar|war|zip)$/
        CFoundry::Zip.unpack(path, to)
      elsif war_file = Dir.glob("#{path}/*.war").first
        CFoundry::Zip.unpack(war_file, to)
      else
        check_unreachable_links(path)

        FileUtils.mkdir(to)

        files = Dir.glob("#{path}/{*,.[^\.]*}")

        exclude = UPLOAD_EXCLUDE
        if File.exists?("#{path}/.vmcignore")
          exclude += File.read("#{path}/.vmcignore").split(/\n+/)
        end

        # adds additional .afignore
        if File.exists?("#{path}/.afignore")
          exclude += File.read("#{path}/.afignore").split(/\n+/)
        end

        # prevent initial copying if we can, remove sub-files later
        files.reject! do |f|
          exclude.any? do |e|
            File.fnmatch(f.sub(path + "/", ""), e)
          end
        end

        FileUtils.cp_r(files, to)

        find_sockets(to).each do |s|
          File.delete s
        end

        # remove ignored globs more thoroughly
        #
        # note that the above file list only includes toplevel
        # files/directories for cp_r, so this is where sub-files/etc. are
        # removed
        exclude.each do |e|
          Dir.glob("#{to}/#{e}").each do |f|
            FileUtils.rm_rf(f)
          end
        end
      end
    end
  end
end
