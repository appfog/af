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
