# Patched to support infra
module CFoundry::V1
  class App
    attribute :infra, :string, :at => [:infra, :provider], :default => 'aws'

    alias_method :infra_name, :infra
    alias_method :infra_name=, :infra=

    def infra
      @client.infra(infra_name)
    end

    def infra=(obj)
      set_named(:infra, obj)
    end

    def inspect
      "\#<#{self.class.name} '#@guid'>"
    end

    # remap payload locations
    write_locations[:framework] = [:staging, :framework]
    write_locations[:runtime] = [:staging, :runtime]
  end
end
