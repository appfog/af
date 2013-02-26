require "af/cli/framework/base"

module VMC::Frameworks
  class Frameworks < Base
    desc "List frameworks"
    group :system
    def frameworks
      frameworks =
        with_progress("Getting frameworks") do
          client.frameworks
        end

      line unless quiet?

      table(
        %w{Name},
        frameworks.collect { |r|
          [c(r.name, :name),
          ]
        })
    end
  end
end
