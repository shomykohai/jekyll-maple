# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = "jekyll-maple"
  spec.version       = "1.0.0"
  spec.authors       = ["Shomy"]
  spec.email         = [""]

  spec.summary       = "A cozy and dreamy jekyll theme inspired by autumn."
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").select { |f| f.match(%r!^(assets|_layouts|_includes|lib|_sass|LICENSE|README.md)!i) }

  spec.add_runtime_dependency "jekyll"
  spec.add_runtime_dependency "jekyll-feed"
  spec.add_runtime_dependency "jekyll-seo-tag"
  spec.add_runtime_dependency "jekyll-paginate-v2"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
end
