require 'file/tail'

module RemoteSyslog
  class FileTailReader
    def initialize(path, options = {}, &block)
      @path = path
      @callback = options[:callback] || block
      @logger   = options[:logger] || Logger.new(STDERR)
      @tag      = options[:program] || File.basename(path)

      # Remove characters that can't be in a tag
      @tag = @tag.gsub(%r{[: \]\[\\]+}, '-')

      # Make sure the tag isn't too long
      if @tag.length > 32
        @tag = @tag[0..31]
      end

      @logger.debug "Watching #{path} with FileTailReader"

      start
    end

    def start
      @thread = Thread.new do
        run
      end
    end

    def run
      File::Tail::Logfile.tail(@path) do |line|
        @callback.call(@tag, line)
      end
    end
  end
end
