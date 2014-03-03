require 'spec_helper'
require 'stringio'

describe 'VMC::Cli::Command::Misc' do

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

  it 'should not raise exception for user with no apps deployed' do
    @client = VMC::Client.new(@local_target, @auth_token)

    info_path = "#{@local_target}/#{VMC::INFO_PATH}"
    stub_request(:get, info_path).to_return(File.new(spec_asset('info_nil_usage.txt')))

    command = VMC::Cli::Command::Misc.new()
    command.client(@client)

    expect {command.info()}.to_not raise_error(/undefined/)
  end

end
