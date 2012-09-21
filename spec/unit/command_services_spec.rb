require 'spec_helper'

describe 'VMC::Cli::Command::Services' do

  include WebMock::API

  before(:all) do
    @target = VMC::DEFAULT_TARGET
    @local_target = VMC::DEFAULT_LOCAL_TARGET
    @user = 'derek@gmail.com'
    @password = 'foo'
    @auth_token = spec_asset('sample_token.txt')
  end

  before(:each) do
    # make sure these get cleared so we don't have tests pass that shouldn't
    RestClient.proxy = nil
    ENV['http_proxy'] = nil
    ENV['https_proxy'] = nil
  end

  describe "import and export" do
    before(:each) do 
      @client = VMC::Client.new(@local_target, @auth_token)

      login_path = "#{@local_target}/users/#{@user}/tokens"
      stub_request(:post, login_path).to_return(File.new(spec_asset('login_success.txt')))
      info_path = "#{@local_target}/#{VMC::INFO_PATH}"
      stub_request(:get, info_path).to_return(File.new(spec_asset('info_authenticated.txt')))
    end
    
    it 'should export a mysql service' do

      command = VMC::Cli::Command::Services.new()
      command.client(@client)
    
      service_path = File.join(@local_target,VMC::SERVICE_EXPORT_PATH,"data")
      stub_request(:get,service_path).to_return(:body=>'{ "uri": "data.zip" }')

      command.export_service('data')
      a_request(:get, service_path).should have_been_made.once 
    end
  
    it 'should import a mysql service' do
      command = VMC::Cli::Command::Services.new()
      command.client(@client)
    
      service_path = File.join(@local_target,VMC::SERVICE_IMPORT_PATH,"data")
      stub_request(:post,service_path)

      command.import_service('data','dl.vcap.me/data')
      a_request(:post, service_path).should have_been_made.once 
    end
  end
  
end
