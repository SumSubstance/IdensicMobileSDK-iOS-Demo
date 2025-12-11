SDK_VERSION = '1.40.2'
IOS_VERSION = '13.0'

platform :ios, IOS_VERSION

source 'https://cdn.cocoapods.org/'
source 'https://github.com/SumSubstance/Specs.git'

target 'IdensicMobileSDK-iOS-Demo' do

  pod 'IdensicMobileSDK', SDK_VERSION
  pod 'IdensicMobileSDK/Fisherman', SDK_VERSION
  pod 'IdensicMobileSDK/MRTDReader', SDK_VERSION
  pod 'IdensicMobileSDK/VideoIdent', SDK_VERSION
#  pod 'IdensicMobileSDK/EID', SDK_VERSION

  pod 'Toast-Swift', '5.1.1', :inhibit_warnings => true
end

post_install do |installer|
  puts "... Pods: update deployment targets to be #{IOS_VERSION} or higher (in order to avoid xcode warnings)"
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      if Gem::Version.new(config.build_settings['IPHONEOS_DEPLOYMENT_TARGET']) < Gem::Version.new(IOS_VERSION)
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = IOS_VERSION
      end
    end
  end
end
