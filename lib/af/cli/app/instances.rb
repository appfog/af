require "vmc/cli/app/base"

module VMC::App
  class Instances < Base
    IS_UTF8 = !!(ENV["LC_ALL"] || ENV["LC_CTYPE"] || ENV["LANG"] || "")["UTF-8"].freeze

    desc "Update the instances limit for an application"
    group :apps
    input :app, :desc => "App to show", :argument => :required,
          :from_given => by_name(:app)
    input :inst, :desc => "Number of instances to run", :argument => :optional

    def instances
      app = input[:app]

      if input.has?(:inst)
        inst = input[:inst]
      else
        inst = input[:inst, app.total_instances]
      end

      app.total_instances = inst if input.has?(:inst)
      fail "No changes!" unless app.changed?

      with_progress("Scaling #{c(app.name, :name)}") do
        app.update!
      end

      if app.started?
        invoke :restart, :app => app
      end

    end

    private

    def ask_inst(default)
      ask("Instances", :default => default)
    end
  end
end
