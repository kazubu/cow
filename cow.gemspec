# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cow/version'

Gem::Specification.new do |spec|
  spec.name          = 'cow'
  spec.version       = Cow::VERSION
  spec.authors       = ['Kazuki Shimizu']
  spec.email         = ['kazubu@kazubu.jp']

  spec.summary       = %q{Console server Wrapper}
  spec.description   = %q{Ease to connect console server ports}
  spec.homepage      = 'https://github.com/kazubu/cow/'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 2.1.0'
  spec.add_development_dependency 'rake', '~> 12.3.3'
  spec.add_dependency 'snmp'
end
