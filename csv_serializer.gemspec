# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'csv_serializer/version'

Gem::Specification.new do |spec|
  spec.name          = "csv_serializer"
  spec.version       = CsvSerializer::VERSION
  spec.authors       = ["Baash05"]
  spec.email         = ["david@airtasker.com"]

  spec.summary       = "Create CSV's from active records, in as close to the way ActiveModel::Serializer works"
  spec.description   = "The creation of JSON from a serializer is quite easy with ActiveModel::Serializer " \
                       "This gem hopes to make the creation of a CSV as simple and as close to the same as the authors can invision"
  spec.homepage      = "https://github.com/airtasker/CSVSerializer"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rails", "~> 4.2.6"
  spec.add_development_dependency "rake", "~> 10.0"
end
