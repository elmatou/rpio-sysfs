
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "rpio/sysfs/version"

Gem::Specification.new do |spec|
  spec.name          = "rpio-sysfs"
  spec.version       = Rpio::Sysfs::VERSION
  spec.authors       = ["Marco"]
  spec.email         = ["elmatou@gmail.com"]

  spec.summary       = %q{GPIO kernel driver library for the Raspberry Pi and PiPiper}
  spec.description   = 'GPIO kernel driver library for the Raspberry Pi and other' \
                       ' boards that use the chipset. Commonly used with the' \
                       ' Rpio ruby library. It implements Pin (with events),' \
                       ' it reads from sysfs'
  spec.homepage      = "https://www.github/elmatou/rpio-sysfs"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

    spec.metadata["homepage_uri"] = spec.homepage
    # spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
    # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end

  spec.require_paths = ["rpio"]
  spec.add_runtime_dependency 'rpio'

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
