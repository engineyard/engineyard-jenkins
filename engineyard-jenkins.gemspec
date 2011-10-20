# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name        = "engineyard-jenkins"
  s.version     = '0.5.0'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Dr Nic Williams"]
  s.email       = ["drnicwilliams@gmail.com"]
  s.homepage    = "http://github.com/engineyard/engineyard-jenkins"
  s.summary     = %q{Easier to do CI than not to. Use Jenkins CI with Engine Yard AppCloud.}
  s.description = %q{Run your continuous integration (CI) tests against your Engine Yard AppCloud environments - the exact same configuration you are using in production!}

  s.rubyforge_project = "engineyard-jenkins"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency("thor", ["~> 0.14.6"])
  s.add_dependency("engineyard", ["~> 1.3.18"])
  s.add_dependency("jenkins", ["~> 0.6.4"])

  s.add_development_dependency("rake", ["~> 0.8.7"])
  s.add_development_dependency("cucumber", ["~> 0.9.4"])
  s.add_development_dependency("rspec", ["~> 2.1.0"])
  s.add_development_dependency("json", ["~>1.4.0"])
  s.add_development_dependency("awesome_print")
  s.add_development_dependency("realweb", '~>0.1.6')
  s.add_development_dependency("open4")
  s.add_development_dependency("sinatra")
  s.add_development_dependency("fakeweb", "~>1.3.0")
end
