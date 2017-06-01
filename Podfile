use_frameworks!

def project_dependencies
  pod 'Runglish',  path: '../Runglish'
  pod 'AudioPlayer', path: '../AudioPlayer'
end

target 'TVSetKit_iOS' do
  platform :ios, '10.0'

  podspec :path => 'TVSetKit.podspec'

  project_dependencies

  target 'TVSetKit_iOSTests' do
    inherit! :search_paths
  end
end

target 'TVSetKit_tvOS' do
  platform :tvos, '10.10'

  podspec :path => 'TVSetKit.podspec'

  project_dependencies

  target 'TVSetKit_tvOSTests' do
    inherit! :search_paths
  end
end

target 'TVSetKit_macOS' do
  platform :osx, '10.10'

  podspec :path => 'TVSetKit.podspec'

  project_dependencies

  target 'TVSetKit_macOSTests' do
    inherit! :search_paths
  end
end
