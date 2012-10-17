module VMC::Cli
  module FileHelper
    
    class AppFogIgnore
      
      def initialize(patterns)
        @patterns = patterns + [ ".git/" ]
      end
        
      def included_files(filenames)
        exclude_dots_only(filenames).reject do |filename|
          exclude = false
          @patterns.each do |pattern|
            if AppFogIgnore.is_negative_pattern?(pattern)
              exclude = false if AppFogIgnore.negative_match(pattern,filename)
            else
              exclude ||= AppFogIgnore.match(pattern,filename)
            end
          end
          exclude
        end
      end
      
      def exclude_dots_only(filenames)
        filenames.reject do |filename|
          base = File.basename(filename)
          base == "." || base == ".."
        end
      end

      
      
      def excluded_files(filenames)
        filenames - included_files(filenames)
      end

      def self.from_file(ignore_path)
        if File.exists?(ignore_path) 
          contents = File.read(ignore_path).split("\n")
          AppFogIgnore.new(contents)
        else
          AppFogIgnore.new([])
        end
      end

      def self.match(pattern,filename)
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
    
      def self.is_negative_pattern?(pattern)
        pattern =~ /^!/
      end
    
      def self.negative_match(pattern,filename)
        return false unless pattern =~ /^!/
        match(pattern.sub(/^!/,''),filename)
      end
      
    end
    
    def ignore_sockets(files)
      files.reject { |f| File.socket? f }
    end
    
    def check_unreachable_links(path,files)
      pwd = Pathname.new(path)
      abspath = pwd.realpath.to_s
      unreachable = []
      files.each do |f|
        file = Pathname.new(f)
        if file.symlink? && !file.realpath.to_s.start_with?(abspath)
          unreachable << file.relative_path_from(pwd).to_s
        end
      end

      unless unreachable.empty?
        root = pwd.relative_path_from(pwd).to_s
        err "Can't deploy application containing links '#{unreachable.join(",")}' that reach outside its root '#{root}'"
      end
    end

    def copy_files(project_root,files,dest_dir)
      files.reject { |f| File.symlink?(f) }.each do |f|
        if File.directory?(f)
          FileUtils.mkdir_p("#{dest_dir}/#{f}")
        else
          FileUtils.cp(f,"#{dest_dir}/#{f}")
        end
      end      
      root = Pathname.new(project_root).realpath
      files.select { |f| File.symlink?(f) }.each do |f|
        p = Pathname.new(f).realpath
        FileUtils.ln_s(p.relative_path_from(root),"#{dest_dir}/#{f}")
      end
    end
    
  end
end