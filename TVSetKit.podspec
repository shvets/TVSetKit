Pod::Spec.new do |s|
  s.name         = "TVSetKit"
  s.version      = "1.0.9"
  s.summary      = "Framework for representing movies as collection and playing them"
  s.description  = "Framework for representing movies as collection and playing them."

  s.homepage     = "https://github.com/shvets/TVSetKit"
  s.authors = { "Alexander Shvets" => "alexander.shvets@gmail.com" }
  s.license      = "MIT"
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '3' }

  s.ios.deployment_target = "10.0"
  #s.osx.deployment_target = "10.10"
  s.tvos.deployment_target = "10.0"
  #s.watchos.deployment_target = "2.0"

  s.source = { :git => "https://github.com/shvets/TVSetKit.git", :tag => s.version }
  s.source_files = "Sources/**/*.swift"

  s.resource_bundles = {
    'com.rubikon.TVSetKit' => ['Sources/**/*.{storyboard,strings}']
  }

  s.dependency 'SwiftyJSON', '~> 3.1.4'
  s.dependency 'Runglish', '~> 1.0.0'
  s.dependency 'AudioPlayer', '~> 1.0.7'
end
