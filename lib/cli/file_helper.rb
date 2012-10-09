module VMC::Cli
  module FileHelper
    
    
    def match(pattern,filename)
      return false if pattern =~ /^\s*$/ # ignore blank lines
      
      return false if pattern =~ /^#/ # lines starting with # are comments
      
      if pattern =~ /\/$/ 
        # pattern ending in a slash should ignore directory and all its children
        dirname = pattern.sub(/\/$/,'')
        return filename == dirname || filename =~ /#{dirname}\/.*$/
      end
      
      if pattern =~ /^!/
        return !match(pattern.sub(/^!/,''),filename)
      end
      
      if pattern =~ /^\//
        parts = filename.split('/')
        return File.fnmatch(pattern.sub(/^\//,''),parts[0])
      end
      
      if pattern.include? '/'
        return File.fnmatch(pattern,filename)
      end
      
      File.fnmatch(pattern,filename,File::FNM_PATHNAME)
    end
    
    def reject_patterns(patterns,filenames)
      filenames.reject do |filename|
        patterns.detect { |pattern| match(pattern,filename)} != nil
      end
    end

    def afignore(ignore_path,files)
      if File.exists?(ignore_path) 
        patterns = File.read(ignore_path).split("\n")
        reject_patterns(patterns,files)
      else
        files
      end
    end
    
  end
end