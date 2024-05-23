platform :ios, '14.0'
use_frameworks!
install! 'cocoapods', :deterministic_uuids => false

target 'MyNotes' do
  # Pods for MyNotes

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
    end
  end
end
