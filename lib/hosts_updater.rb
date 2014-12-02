require 'hosts'
require 'logger'
require 'open-uri'

class HostsUpdater

  SOURCES = {
    :mdl => ['http://www.malwaredomainlist.com/hostslist/hosts.txt', 'Malware Domain List'],
    :mvps => ['http://winhelp2002.mvps.org/hosts.txt', 'MVPS Hosts'],
    :swc => ['http://someonewhocares.org/hosts/hosts', "Dan Pollock's List"],
    :yoyo => ['http://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts&mimetype=plaintext', "Peter Lowe's Ad Server List"]
  }

  DEFAULT_OPTIONS = {
    :hosts_file => '/etc/hosts',
    :hosts_directory => '/etc/hosts.d/',
    :hosts_auto_name => 'hosts.auto',
    :hosts_custom_name => 'hosts.custom',
    :hosts_whitelist_name => 'hosts.whitelist',
    :ip => '0.0.0.0',
    :sources => SOURCES,
    :update => false,
    :quiet => false,
    :verbose => false
  }

  def initialize(options = {})
    sources = options.delete(:sources) || {}
    @options = DEFAULT_OPTIONS.merge(options)
    @options[:sources].merge!(sources)
  end

  def run
    unless ENV['USER'] == 'root'
      logger.error 'Error: Must run as root'
      exit
    end

    bootstrap
    update_auto_file if @options[:update]
    update_hosts_file

    logger.info 'Done.'
  end

  private

  def logger
    return @logger if defined?(@logger)
    @logger = Logger.new(STDOUT)
    @logger.level = if @options[:quiet]
                      Logger::ERROR
                    elsif @options[:verbose]
                      Logger::DEBUG
                    else
                      Logger::INFO
                    end
    @logger.formatter = proc { |severity, datetime, progname, msg| "#{msg}\n" }
    @logger
  end

  # Create /etc/hosts.d and files inside.
  # If /etc/hosts.d/hosts.custom does not exists then it will copy content of /etc/hosts there.
  def bootstrap
    unless Dir.exists? @options[:hosts_directory]
      logger.debug "Creating configuration directory at #{@options[:hosts_directory]}"
      FileUtils.mkdir_p @options[:hosts_directory]
    end

    unless File.exists? hosts_custom_location
      logger.debug "Copying #{@options[:hosts_file]} to #{hosts_custom_location}"
      File.write(hosts_custom_location, File.read(@options[:hosts_file]))
    end

    unless File.exists? hosts_auto_location
      logger.debug "Writing default #{hosts_auto_location}"
      File.touch(hosts_auto_location)
    end

    unless File.exists? hosts_whitelist_location
      logger.debug "Writing default #{hosts_whitelist_location}"
      File.write(hosts_whitelist_location, "# List domains that should be ignored here.\n# One domain per line, lines starting with # will be ignored.\n")
    end
  end

  def update_auto_file
    elements = []
    @options[:sources].each do |source_key, source_data|
      next unless source_data
      elements += download_source(source_data)
    end
    hosts = Hosts::File.new
    hosts.elements = elements.uniq(&:name).sort { |e1,e2| e1.name <=> e2.name }
    hosts.elements.insert 0, Hosts::Comment.new(' This file was auto-generated by hosts-updater.')
    hosts.elements.insert 1, Hosts::Comment.new(' Changes to this file may cause incorrect behavior and will be lost if the code is regenerated.')
    hosts.elements.insert 2, Hosts::EmptyElement.new

    File.write(hosts_auto_location, hosts.to_s(:force_generation => true))
  end

  def update_hosts_file
    auto = Hosts::File.read(hosts_auto_location).elements
    auto.reject! { |el| ! el.is_a? Aef::Hosts::Entry }
    auto.reject! { |el| whitelist.include? el.name }
    auto.each do |el|
      el.address = @options[:ip]
    end

    hosts = Hosts::File.new(@options[:hosts_file])
    hosts.elements = Hosts::File.read(hosts_custom_location).elements
    hosts.elements << Hosts::EmptyElement.new
    hosts.elements << Hosts::Section.new('HOSTS-UPDATER', :elements => auto)
    logger.debug "Writing to #{@options[:hosts_file]}"
    hosts.write
  end

  def download_source(source)
    logger.debug "Downloading source #{source[0]}" + (source[1] ? " (#{source[1]})" : "")
    data = open(source[0])
    Hosts::File.parse(data.read).elements.select { |el| el.is_a? Aef::Hosts::Entry }
  end

  def whitelist
    @whitelist ||= File.read(hosts_whitelist_location).lines.collect(&:strip).reject { |el| /^#/ =~ el }
  end

  def hosts_auto_location
    @options[:hosts_directory] + @options[:hosts_auto_name]
  end

  def hosts_custom_location
    @options[:hosts_directory] + @options[:hosts_custom_name]
  end

  def hosts_whitelist_location
    @options[:hosts_directory] + @options[:hosts_whitelist_name]
  end

end
