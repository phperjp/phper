# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{phper}
  s.version = "0.3.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Yoshihiro TAKAHARA"]
  s.date = %q{2011-02-22}
  s.default_executable = %q{phper}
  s.description = %q{phper}
  s.email = %q{y.takahara@gmail.com}
  s.executables = ["phper"]
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.md"
  ]
  s.files = [
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "README.md",
    "Rakefile",
    "VERSION",
    "bin/phper",
    "lib/phper.rb",
    "lib/phper/agent.rb",
    "lib/phper/cli.rb",
    "lib/phper/commands.rb",
    "phper.gemspec",
    "test/helper.rb",
    "test/test_phper.rb"
  ]
  s.homepage = %q{http://github.com/tumf/phper}
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.5.0}
  s.summary = %q{phper}
  s.test_files = [
    "test/helper.rb",
    "test/test_phper.rb"
  ]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rest-client>, [">= 0"])
      s.add_runtime_dependency(%q<keystorage>, ["> 0.1"])
      s.add_runtime_dependency(%q<highline>, ["> 1.6"])
      s.add_runtime_dependency(%q<command-line-utils>, [">= 0.0.1"])
      s.add_runtime_dependency(%q<launchy>, [">= 0"])
      s.add_runtime_dependency(%q<json>, [">= 0"])
      s.add_development_dependency(%q<shoulda>, [">= 0"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.5.2"])
      s.add_development_dependency(%q<rcov>, [">= 0"])
    else
      s.add_dependency(%q<rest-client>, [">= 0"])
      s.add_dependency(%q<keystorage>, ["> 0.1"])
      s.add_dependency(%q<highline>, ["> 1.6"])
      s.add_dependency(%q<command-line-utils>, [">= 0.0.1"])
      s.add_dependency(%q<launchy>, [">= 0"])
      s.add_dependency(%q<json>, [">= 0"])
      s.add_dependency(%q<shoulda>, [">= 0"])
      s.add_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_dependency(%q<jeweler>, ["~> 1.5.2"])
      s.add_dependency(%q<rcov>, [">= 0"])
    end
  else
    s.add_dependency(%q<rest-client>, [">= 0"])
    s.add_dependency(%q<keystorage>, ["> 0.1"])
    s.add_dependency(%q<highline>, ["> 1.6"])
    s.add_dependency(%q<command-line-utils>, [">= 0.0.1"])
    s.add_dependency(%q<launchy>, [">= 0"])
    s.add_dependency(%q<json>, [">= 0"])
    s.add_dependency(%q<shoulda>, [">= 0"])
    s.add_dependency(%q<bundler>, ["~> 1.0.0"])
    s.add_dependency(%q<jeweler>, ["~> 1.5.2"])
    s.add_dependency(%q<rcov>, [">= 0"])
  end
end

