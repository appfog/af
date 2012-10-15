module VMC::Cli
  module FileHelper
    
    
    def match(pattern,filename)
      return false if pattern =~ /^\s*$/ # ignore blank lines

      return false if pattern =~ /^#/ # lines starting with # are comments

      return false if pattern =~ /^!/ # lines starting with ! are negated
      
      if pattern =~ /\/$/ 
        # pattern ending in a slash should ignore directory and all its children
        dirname = pattern.sub(/\/$/,'')
        return filename == dirname || filename =~ /#{dirname}\/.*$/
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
    
    def is_negative_pattern?(pattern)
      pattern =~ /^!/
    end
    
    def negative_match(pattern,filename)
      return false unless pattern =~ /^!/
      match(pattern.sub(/^!/,''),filename)
    end
    
    def reject_patterns(patterns,filenames)
      filenames.reject do |filename|
        exclude = false
        patterns.each do | pattern|
          if is_negative_pattern?(pattern)
            exclude = false if negative_match(pattern,filename)
          else
            exclude ||= match(pattern,filename)
          end
        end
        exclude
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
    
    def ignore_sockets(files)
      files.reject { |f| File.socket? f }
    end
    
  end
end