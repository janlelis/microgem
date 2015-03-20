# -*- encoding: utf-8 -*-

require File.dirname(__FILE__) + '/lib/microgem/version'

Gem::Specification.new do |gem|
  gem.name          = "microgem"
  gem.version       = Microgem::VERSION
  gem.summary       = "Generates new micro gems."
  gem.description   = "Generates new micro gems. Usage: $ microgem gem_name"
  gem.authors       = ["Jan Lelis"]
  gem.email         = "mail@janlelis.de"
  gem.homepage      = "https://github.com/janlelis/microgem"
  gem.license       = "MIT"

  gem.files         = Dir['{**/}{.*,*}'].select{ |path| File.file?(path) && path !~ /^pkg/ }
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']
end
