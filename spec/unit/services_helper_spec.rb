require 'spec_helper'

describe 'VMC::Cli::ServicesHelper' do

  include VMC::Cli::ServicesHelper

  before(:each) do
  end

  describe "generated service name" do
    
    it 'should replace app name' do
      new_name = generate_cloned_service_name('first','second','first-mysql','aws')
      new_name.should == 'second-mysql'
    end

    it 'should replace random hex number' do
      new_name = generate_cloned_service_name('first','second','mysql-01a94','aws')
      new_name.should =~ /mysql-\h+/
    end

    it 'should append infra name' do
      new_name = generate_cloned_service_name('first','second','my-database','aws')
      new_name.should == 'my-database-aws'
    end
    
  end
  
end