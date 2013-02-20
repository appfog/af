require "af/cli/infra/base"

module VMC::Infra
  class Infras < Base
    desc "List infras"
    group :infras
    input :space, :desc => "Show infras in given space",
          :default => proc { client.current_space },
          :from_given => by_name(:space)
    def infras
      if space = input[:space]
        begin
          space.summarize!
        rescue CFoundry::APIError
        end

        infras =
          with_progress("Getting infras in #{c(space.name, :name)}") do
            space.infras
          end
      else
        infras =
          with_progress("Getting infras") do
            client.infras
          end
      end

      line unless quiet?

      table(
        %w{infra description},
        infras.collect { |r|
          [c(r.name, :infra),c(r.description, :description),
          ]
        })
    end
  end
end