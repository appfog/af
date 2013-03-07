require "vmc/cli/route/base"

module VMC::Route
  class Unmap < Base
    desc "Remove a URL mapping"
    group :apps, :info
    input :app, :desc => "Application to remove the URL from",
          :argument => :optional, :from_given => by_name(:app)
    input :url, :desc => "URL to unmap", :argument => :optional
    input :all, :desc => "Act on all routes", :type => :boolean
    def unmap
      app = input[:app]

      fail "No urls to unmap." if app.urls.empty?

      url = input[:url, (app.urls.map{|url| OpenStruct.new({name: url})})] unless input[:all]

      with_progress("Updating #{c(app.name, :name)}") do |s|
        if input[:all]
          app.urls = []
        else
          simple = url.name.sub(/^https?:\/\/(.*)\/?/i, '\1')

          unless app.urls.delete(simple)
            fail "URL #{url} is not mapped to this application."
          end
        end

        app.update!
      end
    end

    private

    def ask_app
      ask("Which application?", :choices => client.apps, :display => proc(&:name))
    end

    def ask_url(choices)
      ask("Which URL?", :choices => choices.sort_by(&:name), :display => proc(&:name))
    end
  end
end
