require 'spec_helper'
require 'stringio'

describe 'VMC::Cli::Command::User' do

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

  it 'should throw an error when a changed password contains a right curly brace' do
    @client = VMC::Client.new(@local_target, @auth_token)

    info_path = "#{@local_target}/#{VMC::INFO_PATH}"
    stub_request(:get, info_path).to_return(File.new(spec_asset('info_nil_usage.txt')))

    command = VMC::Cli::Command::User.new(:noprompts => 1)
    command.client(@client)

    expect {command.change_password('right}brace]')}.to raise_error(/Passwords may not contain braces/)
  end

  it 'should throw an error when a changed password contains a left curly brace' do
    @client = VMC::Client.new(@local_target, @auth_token)

    info_path = "#{@local_target}/#{VMC::INFO_PATH}"
    stub_request(:get, info_path).to_return(File.new(spec_asset('info_nil_usage.txt')))

    command = VMC::Cli::Command::User.new(:noprompts => 1)
    command.client(@client)

    expect {command.change_password('left{brace]')}.to raise_error(/Passwords may not contain braces/)
  end

end
