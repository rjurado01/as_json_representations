
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'as_json_representations/version'

Gem::Specification.new do |spec|
  spec.name          = 'as_json_representations'
  spec.version       = AsJsonRepresentations::VERSION
  spec.authors       = ['rjurado01']
  spec.email         = ['rjurado01@gmail.com']

  spec.summary       = 'Creates representations of your model data'
  spec.description   = 'Creates representations of your model data in a simple and clean way'
  spec.homepage      = 'https://github.com/rjurado01/as_json_representations'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 2.3'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
