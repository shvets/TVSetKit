source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/shvets/Specs.git'

use_frameworks!

def project_dependencies
  #pod 'Runglish', path: '../Runglish'
  #pod 'ConfigFile', path: '../ConfigFile'
  #pod 'PageLoader', path: '../PageLoader'
end

target 'TVSetKit_iOS' do
  platform :ios, '10.11'

  podspec :path => 'TVSetKit.podspec'

  target 'TVSetKit_iOSTests' do
    inherit! :search_paths
  end
end

target 'TVSetKit_tvOS' do
  platform :tvos, '10.11'

  podspec :path => 'TVSetKit.podspec'

  target 'TVSetKit_tvOSTests' do
    inherit! :search_paths
  end
end

# target 'TVSetKit_macOS' do
#   platform :osx, '10.11'
#
#   podspec :path => 'TVSetKit.podspec'
#
#   project_dependencies
#
#   target 'TVSetKit_macOSTests' do
#     inherit! :search_paths
#   end
# end
