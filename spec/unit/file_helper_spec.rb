require 'spec_helper'

describe 'VMC::Cli::FileHelper' do

  include VMC::Cli::FileHelper

  before(:each) do
  end

  describe "afignore" do
    
    it 'should ignore blank lines' do
      patterns = [ "" ]
      files = %W( index.html )
      reject_patterns(patterns,files).should == %W( index.html )
    end

    it 'should ignore lines starting with #' do
      patterns = [ "# index.html" ]
      files = %W(index.html)
      reject_patterns(patterns,files).should == %W( index.html )
    end

    it 'should ignore literal matches' do
      patterns = %W(index1.html index3.html)
      files = %W(index1.html index2.html index3.html)
      reject_patterns(patterns,files).should == %W( index2.html )
    end
    
    it 'should not match / in pattern with wildcard' do
      patterns = [ "*.html" ]
      files = %W(index.html public/index.html)
      reject_patterns(patterns,files).should == %W( public/index.html )
    end
    
    it 'should ignore directories for patterns ending in slash' do
      patterns = %W( public/ )
      files = %W(index.html public public/first public/second script/foo.js)
      reject_patterns(patterns,files).should == %W( index.html script/foo.js)
    end
    
    it 'should negate test for patterns starting with !' do
      patterns = %W( !index.html )
      files = %W( index.html index2.html index3.html lib/shared.so)
      reject_patterns(patterns,files).should == %W(index.html)
    end
    
    it 'should match beginning of path for leading /' do 
      patterns = %W( /*.c )
      files = %W( foo.c lib/foo.c )
      reject_patterns(patterns,files).should == %W(lib/foo.c)
    end
    
    it 'should read patterns from .afignore' do 
      File.should_receive(:exists?).with('.afignore').and_return(true)
      File.should_receive(:read).with('.afignore').and_return("index2.html\nindex3.html")
      results = afignore('.afignore',%W(index.html index2.html index3.html index4.html))
      results.should == %W(index.html index4.html)
    end
    
  end
  
end