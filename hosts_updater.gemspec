# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "hosts_updater/version"

Gem::Specification.new do |s|
  s.name        = "hosts_updater"
  s.version     = HostsUpdater::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Bernard Potocki"]
  s.email       = ["bernard.potocki@imanel.org"]
  s.homepage    = "http://github.com/imanel/hosts_updater"
  s.summary     = %q{Update your /etc/hosts with list of unwanted domains}
  s.description = %q{Update your /etc/hosts with list of unwanted domains}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.lines.map { |f| File.basename(f.chomp) }
  s.require_paths = ["lib"]

  s.add_dependency('hosts', '~> 0.1.1')
  s.add_dependency('sudo', '~> 0.1.1')
end
