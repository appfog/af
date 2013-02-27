require "vmc/cli/app/base"

module VMC::App
  class Mem < Base
    IS_UTF8 = !!(ENV["LC_ALL"] || ENV["LC_CTYPE"] || ENV["LANG"] || "")["UTF-8"].freeze

    desc "Show app memory usage"
    group :apps
    input :app, :desc => "App to show", :argument => :required,
          :from_given => by_name(:app)
    def mem
      app = input[:app]

      if quiet?
        line app.name
      else
        display_app(app)
      end
    end

    def display_app(a)
      status = app_status(a)

      line "#{c(a.name, :name)}: #{status}"

      indented do
        start_line "usage: #{b(human_mb(a.memory))}"
        print " #{d(IS_UTF8 ? "\xc3\x97" : "x")} #{b(a.total_instances)}"

        line
      end
    end
  end
end
