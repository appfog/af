require "af/cli/runtime/base"

module VMC::Runtimes
  class Runtimes < Base
    desc "List runtimes"
    group :system
    def runtimes
      runtimes =
        with_progress("Getting runtimes") do
          client.runtimes
        end

      line unless quiet?

      table(
        %w{runtime description},
        runtimes.collect { |r|
          [c(r.name, :name),c(r.description, :description),
          ]
        })
    end
  end
end
