require 'base64'
require 'net/http'
require 'uaa/util'

module CFoundry
  class UAAClient
    def prompts
      wrap_uaa_errors do
        puts "CFoundry wrap_uaa_errors #{target}"
        CF::UAA::Misc.server(target)[:prompts]
      end
    end
  end
end

module CFoundry
  class BaseClient
    def uaa
      @uaa ||= begin
        puts info
        #endpoint = info[:authorization_endpoint]
        endpoint = "http://localhost:9999"
        uaa = CFoundry::UAAClient.new(endpoint)
        uaa.trace = trace
        uaa.token = token
        uaa
      end
    end
  end
end

module CF::UAA
  class Misc
    def self.server(target)
      puts target
      reply = {}
      reply[:prompts] = {:username => ['string', 'Username'], :password => ['password', 'Password']}
      return reply
      reply = json_get(target, '/login', @key_style)
      puts "reply #{reply}"
      
      return reply if reply && (reply[:prompts] || reply['prompts'])
      raise BadResponse, "Invalid response from target #{target}"
    end
  end
  module Http
    def request(target, method, path, body = nil, headers = {})
      puts "Http request!!!!!!!!!!!!!!!!!!!!!!!!!!!!:#{target}"
      headers["accept"] = headers["content-type"] if headers["content-type"] && !headers["accept"]
      url = "#{target}#{path}"

      logger.debug { "--->\nrequest: #{method} #{url}\n" +
          "headers: #{headers}\n#{'body: ' + Util.truncate(body.to_s, trace? ? 50000 : 50) if body}" }
      status, body, headers = @req_handler ? @req_handler.call(url, method, body, headers) :
          net_http_request(url, method, body, headers)
      logger.debug { "<---\nresponse: #{status}\nheaders: #{headers}\n" +
          "#{'body: ' + Util.truncate(body.to_s, trace? ? 50000: 50) if body}" }

      [status, body, headers]

    rescue Exception => e
      logger.debug { "<---- no response due to exception: #{e.inspect}" }
      raise e
    end


    def net_http_request(url, method, body, headers)
      puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!:#{url}"
      throw "AAAAAAAA"
      raise ArgumentError unless reqtype = {:delete => Net::HTTP::Delete,
          :get => Net::HTTP::Get, :post => Net::HTTP::Post, :put => Net::HTTP::Put}[method]
      headers["content-length"] = body.length if body
      puts url
      uri = URI.parse(url)
      req = reqtype.new(uri.request_uri)
      headers.each { |k, v| req[k] = v }
      http_key = "#{uri.scheme}://#{uri.host}:#{uri.port}"
      @http_cache ||= {}
      unless http = @http_cache[http_key]
        @http_cache[http_key] = http = Net::HTTP.new(uri.host, uri.port)
        if uri.is_a?(URI::HTTPS)
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end
      end
      puts "before"
      reply, outhdrs = http.request(req, body), {}
      puts reply
      reply.each_header { |k, v| outhdrs[k] = v }
      [reply.code.to_i, reply.body, outhdrs]

    rescue URI::Error, SocketError, SystemCallError => e
      raise BadTarget, "error: #{e.message}"
    rescue Net::HTTPBadResponse => e
      raise HTTPException, "HTTP exception: #{e.class}: #{e}"
    end
  end
end


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
  class Base
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
