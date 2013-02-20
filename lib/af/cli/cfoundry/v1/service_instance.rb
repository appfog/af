# Patched to support infra
module CFoundry::V1
  class ServiceInstance
    attribute :infra, :string, :at => [:infra, :provider], :default => 'aws'

    alias_method :infra_name, :infra
    alias_method :infra_name=, :infra=

    def infra
      @client.infra(infra_name)
    end

    def infra=(obj)
      set_named(:infra, obj)
    end
  end
end
