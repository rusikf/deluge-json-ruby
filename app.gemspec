# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.authors       = ['James Sherwood-Jones']
  gem.email         = ['sherz@jsherz.com']
  gem.description   = ''
  gem.summary       = 'Ruby library for the Deluge web interface.'
  gem.files         = `git ls-files`.split($OUTPUT_RECORD_SEPARATOR)
  gem.homepage      = 'https://github.com/jSherz/deluge-json-ruby'
  gem.executables   = gem.files.grep(/^bin/).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(/^(test|features)/)
  gem.name          = 'deluge-json'
  gem.require_paths = ['lib']
  gem.version       = '2.0.0'
  gem.add_dependency('httparty')
end
