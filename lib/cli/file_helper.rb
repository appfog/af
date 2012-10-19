module VMC::Cli
  module FileHelper
    
    class AppFogIgnore
      
      def initialize(patterns,project_root = "")
        @patterns = patterns + [ ".git/" ]
        @project_root = project_root
      end
      
      def included_files(filenames)
        exclude_dots_only(filenames).reject do |filename|
          exclude = false
          @patterns.each do |pattern|
            if is_negative_pattern?(pattern)
              exclude = false if negative_match(pattern,filename)
            else
              exclude ||= match(pattern,filename)
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

      def self.from_file(project_root)
        f = "#{project_root}/.afignore"
        if File.exists?(f) 
          contents = File.read(f).split("\n")
          AppFogIgnore.new(contents,project_root)
        else
          AppFogIgnore.new([],project_root)
        end
      end

      def match(pattern,filename)

        filename = filename.sub(/^#{@project_root}\//,'') # remove any project directory prefix

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
      project_root = Pathname.new(project_root)
      files.reject { |f| File.symlink?(f) }.each do |f|
        dest = Pathname.new(f).relative_path_from(project_root)
        if File.directory?(f)
          FileUtils.mkdir_p("#{dest_dir}/#{dest}")
        else
          FileUtils.cp(f,"#{dest_dir}/#{dest}")
        end
      end      
      root = Pathname.new(project_root).realpath
      files.select { |f| File.symlink?(f) }.each do |f|
        dest = Pathname.new(f).relative_path_from(project_root)
        p = Pathname.new(f).realpath
        FileUtils.ln_s(p.relative_path_from(root),"#{dest_dir}/#{dest}")
      end
    end
    
  end
end