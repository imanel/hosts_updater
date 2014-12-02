class HostsUpdater

  DEFAULT_OPTIONS = {
  }

  def initialize(options = {})
    @options = DEFAULT_OPTIONS.merge(options)
  end

  def run
    puts @options.inspect
  end

end
