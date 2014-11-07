require 'fileutils'
require 'zip/zipfilesystem'
require 'pathname'

module VMC::Cli

  class ZipUtil

    PACK_EXCLUSION_GLOBS = ['..', '.', '*~', '#*#', '*.log']

    class << self

      def to_dev_null
        if WINDOWS
          'nul'
        else
          '/dev/null'
        end
      end

      def entry_lines(file)
        contents = nil
        unless VMC::Cli::Config.nozip
          contents = `unzip -l #{file} 2> #{to_dev_null}`
          contents = nil if $? != 0
        end
        # Do Ruby version if told to or native version failed
        unless contents
          entries = []
          Zip::ZipFile.foreach(file) { |zentry| entries << zentry }
          contents = entries.join("\n")
        end
        contents
      end

      def unpack(file, dest)
        unless VMC::Cli::Config.nozip
          FileUtils.mkdir(dest)
          `unzip -q #{file} -d #{dest} 2> #{to_dev_null}`
          return unless $? != 0
        end
        # Do Ruby version if told to or native version failed
        Zip::ZipFile.foreach(file) do |zentry|
          epath = "#{dest}/#{zentry}"
          dirname = File.dirname(epath)
          FileUtils.mkdir_p(dirname) unless File.exists?(dirname)
          zentry.extract(epath) unless File.exists?(epath)
        end
      end

      def get_files_to_pack(dir)
        Dir.glob("#{dir}/**/*", File::FNM_DOTMATCH).select do |f|
          process = true
          PACK_EXCLUSION_GLOBS.each { |e| process = false if File.fnmatch(e, File.basename(f)) }
          process && File.exists?(f)
        end
      end

      def pack(dir, zipfile)
        unless VMC::Cli::Config.nozip
          excludes = PACK_EXCLUSION_GLOBS.map { |e| "\\#{e}" }
          excludes = excludes.join(' ')
          Dir.chdir(dir) do
            `zip -y -q -r #{zipfile} . -x #{excludes} 2> #{to_dev_null}`
            return unless $? != 0
          end
        end
        # Do Ruby version if told to or native version failed
        Zip::ZipFile::open(zipfile, true) do |zf|
          get_files_to_pack(dir).each do |f|
            zf.add(f.sub("#{dir}/",''), f)
          end
        end
      end

      BLOCKSIZE_TO_READ = 1024 * 1000

      # not a valid tar file, since tar files include last modified date which breaks it for
      # use in hashing. this method just wraps up everything for use in hashing.
      def tar(path)
        tar_filename = Pathname.new(path).realpath.to_path + '.tar'
        File.open(tar_filename, 'wb') do |tarfile|
          get_files_to_pack(path).each do |file|
            if File.file?(file)
              File.open(file, 'rb') do |f|
                while buffer = f.read(BLOCKSIZE_TO_READ)
                  tarfile.write buffer
                end
              end
            else
              tarfile.write file.gsub(path, '')
            end
          end
        end

        tar_filename

      end

    end
  end
end
