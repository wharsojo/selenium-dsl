$:.push File.expand_path("../lib",__FILE__)
require 'selenium_dsl/version'

Gem::Specification.new do |s|
	s.name       = "selenium-dsl"
	s.version    = SeleniumDsl::Version
	s.author     = ["WHarsojo"]
	s.email      = ["wharsojo@gmail.com"]
	s.homepage   = "http://github.com/wharsojo/selenium-dsl"
	s.summary    = %q{Simple DSL for Selenium}

	s.rubyforge_project = "selenium-dsl"

	s.files      = %w[Gemfile Gemfile.lock Rakefile selenium-dsl.gemspec bin/sd bin/selenium-dsl lib/selenium_dsl.rb lib/selenium_dsl/commands.rb lib/selenium_dsl/engines.rb lib/selenium_dsl/modules.rb lib/selenium_dsl/macros.rb] 

	s.test_files = []

	s.require_paths = ["lib"] 
    s.executables   = ["sd","selenium-dsl"]
	s.add_runtime_dependency "selenium-webdriver"
	s.add_runtime_dependency "pry"
	s.add_runtime_dependency "term-ansicolor"
	s.post_install_message = ">>Enjoy your SDSL!!!<<"
end
