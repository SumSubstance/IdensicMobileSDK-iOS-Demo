platform :ios, '12.2'

source 'https://cdn.cocoapods.org/'
source 'https://github.com/SumSubstance/Specs.git'

target 'IdensicMobileSDK-iOS-Demo' do

  pod 'IdensicMobileSDK', '1.34.0'
  pod 'IdensicMobileSDK/MRTDReader', '1.34.0'
  pod 'IdensicMobileSDK/VideoIdent','1.34.0'
  pod 'IdensicMobileSDK/EID','1.34.0'

  pod 'Toast-Swift', '5.0.1'
end

post_install do |installer|
  puts "... Pods: update deployment targets to be 12.2 or higher (in order to avoid xcode warnings)"
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      if Gem::Version.new(config.build_settings['IPHONEOS_DEPLOYMENT_TARGET']) < Gem::Version.new('12.2')
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.2'
      end
    end
  end
end
