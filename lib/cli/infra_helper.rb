

module VMC::Cli
  module InfraHelper

    class << self 

      def base_for_infra(infra)
        infras.has_key?(infra) ?  infras[infra][:base] : "aws.af.cm"
      end

      def valid?(infra) 
        infra && infras.has_key?(infra)
      end

      private
      def infras
        { 
          "ap-aws" => { :base => "ap01.aws.af.cm" },
          "eu-aws" => { :base => "eu01.aws.af.cm" },
          "rs"     => { :base => "rs.af.cm" },
          "aws"    => { :base => "aws.af.cm" }
        }
      end

    end

  end
end
