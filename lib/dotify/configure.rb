require 'rbconfig'
require 'thor/util'

module Dotify
  class Configure

    class << self
      def dir
        File.join(self.root, '.dotify')
      end
      def file
        File.join(self.dir, '.dotrc')
      end
      def root
        Thor::Util.user_home
      end
      def path name
        File.join(dir, name)
      end
    end

    class NullSetting < Object
      def initialize name
        @name = name
      end
      def method_missing name, *args, &blk
        self
      end
      def nil?; true; end
      def present?; !nil?; end
      def to_a; []; end
      def to_ary; []; end
      def to_s; ''; end
      def to_i; 0; end
      def to_f; 0.0; end
    end

    def method_missing name, *args, &blk
      if @options[name.to_sym]
        @options[name.to_sym]
      else
        NullSetting.new(name)
      end
    end

    def initialize options = {}
      @options = options
      load!
    end

    def options
      @options ||= {}
    end

    def load!
      DSL.new(@options).__evaluate File.expand_path("~/.dotify/.dotrc")
    end

    def ignoring what
      @ignoring[:shared] | @ignoring[what]
    end

    class DSL
      Protected = %r/^__|^object_id|instance_eval$/

      instance_methods.each do |m|
        undef_method m unless m[Protected]
      end

      def initialize options = {}
        @options = options
      end

      def __evaluate path
        if File.exists? path
          instance_eval File.read(path), path, 1
        end
      end

      def platform which, &blk
        if which.to_sym == Configure.guess_host_os
          instance_eval(&blk)
        end
      end

      def editor editor
        @options[:editor] = editor
      end

      def repo repo
        @options[:repo] = repo
      end

      def github gh
        @options[:github] = gh
      end

      def ignore where, what
        @options[:ignore] ||= {}
        @options[:ignore][where] = (@options[:ignore][where] || []) | what
      end

    end

    private

      def default_ignore
        @ignoring ||= {}
        if @ignoring.empty?
          @ignoring[:shared] = %w[. .. .DS_Store]
          @ignoring[:root] = %w[.rbenv .rvm]
          @ignoring[:path] = %w[.git .gitignore .gitmodules]
        end
      end

      def self.guess_host_os
        @host ||= case host_os
                  when /darwin/i        then :mac
                  when /mswin|windows/i then :windows
                  when /linux/i         then :linux
                  when /sunos|solaris/i then :solaris
                  else :unknown
                  end
      end

      def self.host_os
        RbConfig::CONFIG['host_os']
      end

  end
end