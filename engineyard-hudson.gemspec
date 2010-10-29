# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "engineyard-hudson"

Gem::Specification.new do |s|
  s.name        = "engineyard-hudson"
  s.version     = Engineyard::Hudson::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Dr Nic Williams"]
  s.email       = ["drnicwilliams@gmail.com"]
  s.homepage    = "http://github.com/engineyard/engineyard-hudson"
  s.summary     = %q{Easier to do CI than not to. Use Hudson CI on Engine Yard AppCloud.}
  s.description = %q{Either create a Hudson CI server; or use your Engine Yard AppCloud environments for Hudson slaves.}

  s.rubyforge_project = "engineyard-hudson"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency("thor", ["~> 0.14.3"])

  s.add_development_dependency("rake", ["~> 0.8.7"])
  s.add_development_dependency("cucumber", ["~> 0.9.0"])
  s.add_development_dependency("rspec", ["~> 2.0.0"])
  s.add_development_dependency("json", ["~>1.4.0"])
  s.add_development_dependency("awesome_print")
end
