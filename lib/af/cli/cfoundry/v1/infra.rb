module CFoundry::V1
  class Infra
    attr_accessor :name
    attr_accessor :infra
    attr_accessor :description
    attr_accessor :base
    attr_accessor :locality
    attr_accessor :vendor

    def initialize(name, infra = nil, description = nil, base = nil, locality = nil, vendor = nil)
      @name = name
      @infra = infra
      @description = description
      @locality = locality
      @vendor = vendor
      @base = base
    end

    def eql?(other)
      other.is_a?(self.class) && other.name == @nameidp
    end
    alias :== :eql?

    def apps
      [] # not supported by v1
    end
  end
end
