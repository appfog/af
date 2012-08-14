

module VMC::Cli
  module InfraHelper

    class << self 

      def list
        infras.values
      end

      def base_for_infra(infra)
        infras.has_key?(infra) ?  infras[infra][:base] : "aws.af.cm"
      end

      def valid?(infra) 
        infra && infras.has_key?(infra)
      end

      def infra_descriptions
        infras.map { |k,v| v[:description] }
      end
      
      def name_for_description(desc) 
        name, info = infras.detect { |k,v| v[:description] == desc }
        name
      end
      
      private
      def infras
        { 
          "ap-aws" => { :name => "ap-aws", :base => "ap01.aws.af.cm", :description => "AWS Asia SE - Singapore" },
          "eu-aws" => { :name => "eu-aws", :base => "eu01.aws.af.cm", :description => "AWS EU West - Ireland" },
          "rs"     => { :name => "rs", :base => "rs.af.cm", :description => "Rackspace AZ 1 - Dallas" },
          "aws"    => { :name => "aws", :base => "aws.af.cm", :description => "AWS US East - Virginia" }
        }
      end

    end

  end
end
