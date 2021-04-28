platform :ios, '9.0'

source 'https://cdn.cocoapods.org/'
source 'https://github.com/SumSubstance/Specs.git'

target 'IdensicMobileSDK-iOS-Demo' do

  pod 'IdensicMobileSDK', '=1.17.2'

  pod 'Toast-Swift'
  pod 'IQKeyboardManagerSwift'
end

post_install do |installer|
  puts "... Pods: update deployment targets to be 9.0 or higher (in order to avoid xcode warnings)"
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      if Gem::Version.new(config.build_settings['IPHONEOS_DEPLOYMENT_TARGET']) < Gem::Version.new('9.0')
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.0'
      end
    end
  end

  puts "... Pods: exclude arm64 from builds against iphonesimulator sdk (in order to be able to run on Simulator on Apple M1)"
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
    end
  end
end
