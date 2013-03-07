require "vmc/cli/route/base"

module VMC::Route
  class Map < Base
    def precondition; end

    desc "Add a URL mapping"
    group :apps, :info
    input :app, :desc => "Application to add the URL to",
          :argument => :optional, :from_given => by_name(:app)
    input :url, :desc => "URL to map", :argument => :optional
    def map
      app = input[:app]
      url = input[:url]

      with_progress("Updating #{c(app.name, :name)}") do
        app.urls << url
        app.update!
      end
    end

    private

    def ask_app
      ask("Which application?", :choices => client.apps, :display => proc(&:name))
    end

    def ask_url
      ask("Enter URL?")
    end
  end
end
