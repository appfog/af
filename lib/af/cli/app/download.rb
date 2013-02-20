require 'open-uri'
require "vmc/cli/app/base"

module VMC::App
  class Download < Base
    desc "Downloads last pushed source to zipfile"
    group :apps, :download
    input :app, :desc => "Application to pull", :argument => :optional,
          :from_given => by_name(:app)
    input :path,      :desc => "Path to store app"

    def download
      app = input[:app]
      path = File.expand_path(input[:path] || "#{app.name}.zip")
      with_progress("Downloading last pushed source code to #{c(path, :path)}") do
        client.app_download(app.name, path)
      end
    end

    def ask_app
      apps = client.apps
      fail "No applications." if apps.empty?

      ask("Download which application?", :choices => apps.sort_by(&:name),
          :display => proc(&:name))
    end
  end
end
