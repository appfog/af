require 'spec_helper'

describe 'VMC::Cli::FileHelper' do

  include VMC::Cli::FileHelper

  before(:each) do
  end

  describe "afignore" do
    
    before :each do
      @af = VMC::Cli::FileHelper
    end
    
    it 'should ignore blank lines' do
      afi = VMC::Cli::FileHelper::AppFogIgnore.new([ "" ])
      files = %W( index.html )
      afi.included_files(files).should == %W( index.html )
    end

    it 'should ignore lines starting with #' do
      afi = VMC::Cli::FileHelper::AppFogIgnore.new([ "# index.html" ])
      files = %W(index.html)
      afi.included_files(files).should == %W( index.html )
    end

    it 'should ignore literal matches' do
      afi = VMC::Cli::FileHelper::AppFogIgnore.new(%W(index1.html index3.html))
      files = %W(index1.html index2.html index3.html)
      afi.included_files(files).should == %W( index2.html )
    end

    it 'should not match / in pattern with wildcard' do
      afi = VMC::Cli::FileHelper::AppFogIgnore.new([ "*.html" ])
      files = %W(index.html public/index.html)
      afi.included_files(files).should == %W( public/index.html )
    end
    
    it 'should ignore directories for patterns ending in slash' do
      afi = VMC::Cli::FileHelper::AppFogIgnore.new(%W( public/ ))
      files = %W(index.html public public/first public/second script/foo.js)
      afi.included_files(files).should == %W( index.html script/foo.js)
    end
    
    it 'should reverse previous matches for patterns starting with !' do
      afi = VMC::Cli::FileHelper::AppFogIgnore.new(%W( *.html !index[23].html ))
      files = %W( index.html index2.html index3.html index4.html lib/shared.so)
      afi.included_files(files).should == %W(index2.html index3.html lib/shared.so)
    end

    it 'should not reverse later matches for patterns starting with !' do
      afi = VMC::Cli::FileHelper::AppFogIgnore.new(%W( !index[23].html *.html  ))
      files = %W( index.html index2.html index3.html index4.html lib/shared.so)
      afi.included_files(files).should == %W(lib/shared.so)
    end
    
    it 'should match beginning of path for leading /' do 
      afi = VMC::Cli::FileHelper::AppFogIgnore.new(%W( /*.c ))
      files = %W( foo.c lib/foo.c )
      afi.included_files(files).should == %W(lib/foo.c)
    end
    
    it 'can return files excluded by .afignore' do
      afi = VMC::Cli::FileHelper::AppFogIgnore.new(%W(index1.html index3.html))
      files = %W(index1.html index2.html index3.html)
      afi.excluded_files(files).should == %W( index1.html index3.html )
    end
    
    it 'should ignore .git directory by default' do
      afi = VMC::Cli::FileHelper::AppFogIgnore.new([])
      files = %W(index.html .git/config )
      afi.included_files(files).should == %W( index.html )
    end
    
    it 'should read patterns from .afignore' do 
      files = %W(index.html index2.html index3.html index4.html)
      File.should_receive(:exists?).with('.afignore').and_return(true)
      File.should_receive(:read).with('.afignore').and_return("index2.html\nindex3.html")
      afi = VMC::Cli::FileHelper::AppFogIgnore.from_file('.afignore')
      afi.included_files(files).should == %W(index.html index4.html)
    end
    
  end
  
  describe "sockets" do
    it 'should ignore socket files' do
      File.should_receive(:socket?).with('a-socket').and_return(true)
      File.should_receive(:socket?).with('not-a-socket').and_return(false)
      results = ignore_sockets(%W(a-socket not-a-socket))
      results.should == %W(not-a-socket)
    end
  end
  
  describe "unreachable links" do
    
    it 'raise exception for links outside project directory' do
      @project = double('pathname',
        :realpath => "/project", 
        :relative_path_from => "."
        )      
      @internal = double('pathname', 
        :realpath => "/project/internal", 
        :symlink? => true
        )
      @external = double('pathname',
        :realpath => "/somewhere/else",
        :symlink? => true,
        :relative_path_from => "external"
        )
        
      Pathname.should_receive(:new).with("/project").and_return(@project)
      Pathname.should_receive(:new).with("/project/internal").and_return(@internal)
      Pathname.should_receive(:new).with("/project/external").and_return(@external)
      
      expect {
        check_unreachable_links('/project',%W(/project/internal /project/external))        
      }.to raise_error(VMC::Cli::CliExit)
    end
  end
  
end