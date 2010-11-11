$:.unshift(File.dirname(__FILE__) + '/lib')
require 'nom_nom_nom/version'

Gem::Specification.new do |s|
  s.name = 'nomnomnom-client'
  s.version = NomNomNom::VERSION
  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true
  s.extra_rdoc_files = ["README.rdoc", "LICENSE" ]
  s.summary = "A Notification/Exeception handler for Chef."
  s.description = s.summary
  s.author = "Daniel DeLeo"
  s.email = "dan@opscode.com"
  s.homepage = "http://github.com/danielsdeleo/nom_nom_nom"

  s.add_dependency "chef", "~> 0.9.0"
  s.add_dependency "yajl-ruby", ">= 0.7.8"
  s.add_dependency "rest-client", "~> 1.6.1"

  s.bindir       = "bin"
  s.executables  = %w( nomnom-test )
  s.require_path = 'lib'
  s.files = %w(LICENSE README.rdoc) + Dir.glob("lib/**/*")
end
