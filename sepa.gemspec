lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sepa/version'

Gem::Specification.new do |s|
  # Metadata
  s.name         = "sepa"
  s.version      = Sepa::VERSION.dup
  s.platform     = Gem::Platform::RUBY
  s.authors      = ["Félix Bellanger"]
  s.email        = ["felix.bellanger@gmail.com"]
  s.description  = "This gem allows you to generate XML documents for SEPA Direct Debit (SDD)."
  s.summary      = "SEPA Direct Debit (SDD) XML Generator."
  s.homepage     = "https://github.com/Keeguon/sepa"
  s.license      = "MIT"

  # Manifest
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,s,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # Dependencies
  s.add_dependency "nokogiri"
end