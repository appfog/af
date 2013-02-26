require "vmc/cli/app/base"

module VMC::App
  class Apps < Base

    def display_apps_table(apps)
      table(
        ["name", "infra", "status", "usage", v2? && "plan", "runtime", "urls"],
        apps.collect { |a|
          [ c(a.name, :name),
            c(a.infra.name, :infra),
            app_status(a),
            "#{a.total_instances} x #{human_mb(a.memory)}",
            v2? && (a.production ? "prod" : "dev"),
            a.runtime.name,
            if a.urls.empty?
              d("none")
            elsif a.urls.size == 1
              a.url
            else
              a.urls.join(", ")
            end
          ]
        })
    end
  end
end
