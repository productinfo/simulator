Pod::Spec.new do |s|
  s.name             = "Simulator"
  s.version          = "1.0.0"
  s.summary          = "Interact with the Xcode simulators"
  s.homepage         = "https://github.com/tuist/simulator"
  s.social_media_url = 'https://twitter.com/pepibumur'
  s.license          = 'MIT'
  s.source           = { :git => "https://github.com/tuist/simulator.git", :tag => s.version.to_s }
  s.requires_arc = true
  s.authors = "Tuist"

  s.osx.deployment_target = '10.10'

  s.source_files = "Sources/**/*.{swift}"

  s.dependency "Shell", "~> 1.1.0"
  s.dependency "Result", "~> 4.1.0"
end