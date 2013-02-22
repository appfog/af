module CFoundry::V1
  class Service
    attr_accessor :label, :infra, :version, :description, :type, :provider, :state, :plans, :default_plan

    def initialize(label, infra, version = nil, description = nil,
                   type = nil, provider = "core", state = nil,
                   plans = [], default_plan = nil)
      @label = label
      @infra = infra
      @description = description
      @version = version
      @type = type
      @provider = provider
      @state = state
      @plans = plans
      @default_plan = default_plan
    end

    def eql?(other)
      other.is_a?(self.class) && other.label == @label
    end
    alias :== :eql?

    def active
      true
    end

    def deprecated?
      @state == :deprecated
    end

    def current?
      @state == :current
    end
  end
end