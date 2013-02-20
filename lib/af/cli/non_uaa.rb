module CFoundry
  class AuthToken
    class << self
      def from_cc_token(token_string)
        new(token_string)
      end
    end
  end

  class BaseClient
    def uaa
      return @uaa unless @uaa.nil?

      endpoint = info[:authorization_endpoint]

      return @uaa = false unless endpoint
      @uaa = CFoundry::UAAClient.new(endpoint)
      @uaa.trace = @trace
      @uaa.token = @token
      @uaa
    end
  end

  module LoginHelpers
    def login_prompts
      if @base.uaa
        @base.uaa.prompts
      else
        {
          :username => %w[text Email],
          :password => %w[password Password]
        }
      end
    end

    def login(username, password)
      token =
        if @base.uaa
          AuthToken.from_uaa_token_info(@base.uaa.authorize(username, password))
        else
          AuthToken.from_cc_token(@base.create_token({:password => password}, username)[:token])
        end

      @base.token = token
    end
  end
end
