# frozen_string_literal: true

require_relative "lib/choron_role_policy/version"

Gem::Specification.new do |spec|
  spec.name = "choron_role_policy"
  spec.version = ChoronRolePolicy::VERSION
  spec.authors = ["mksava"]
  spec.email = ["dosec.mk@gmail.com"]

  spec.summary = "Like AWS policies and role definitions, you can configure authorization settings for app operations."
  spec.description = "Like AWS policies and role definitions, you can configure authorization settings for app operations."
  spec.homepage = "https://github.com/mksava/choron_role_policy"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7.2"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/mksava/choron_role_policy"
  spec.metadata["changelog_uri"] = "https://github.com/mksava/choron_role_policy/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
