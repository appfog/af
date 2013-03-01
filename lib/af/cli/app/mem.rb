require "vmc/cli/app/base"

module VMC::App
  class Mem < Base
    IS_UTF8 = !!(ENV["LC_ALL"] || ENV["LC_CTYPE"] || ENV["LANG"] || "")["UTF-8"].freeze

    desc "Show app memory usage"
    group :apps
    input :app, :desc => "App to show", :argument => :required,
          :from_given => by_name(:app)
    input :mem, :desc => "Memory limit", :argument => :optional

    def mem
      app = input[:app]

      if input.has?(:mem)
        mem = input[:mem]
      else
        mem = input[:mem, app.memory]
      end

      app.memory = megabytes(mem) if input.has?(:mem)
      fail "No changes!" unless app.changed?

      with_progress("Scaling #{c(app.name, :name)}") do
        app.update!
      end

      if app.started?
        invoke :restart, :app => app
      end

    end

    private

    def ask_mem(default)
      ask("Memory Limit", :choices => memory_choices(default),
          :default => human_mb(default), :allow_other => true)
    end
  end
end
