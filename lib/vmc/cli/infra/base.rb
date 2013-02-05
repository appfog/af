require "vmc/cli"

module CFoundry::V1
  class Client
    include ClientMethods, CFoundry::LoginHelpers
    attr_reader :base
    def infras
      @base.get("info", "infras", :accept => :json)
    end
  end
end

module VMC
  module Infra
    class Base < CLI

    end
  end
end