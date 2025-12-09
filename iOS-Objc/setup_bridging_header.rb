require 'xcodeproj'

project_path = 'iOS-Objc/iOS-Objc.xcodeproj'
project = Xcodeproj::Project.open(project_path)

target = project.targets.find { |t| t.name == 'iOS-Objc' }

if target
  puts "Found target: #{target.name}"
  target.build_configurations.each do |config|
    config.build_settings['SWIFT_OBJC_BRIDGING_HEADER'] = 'iOS-Objc/iOS-Objc-Bridging-Header.h'
    puts "Set SWIFT_OBJC_BRIDGING_HEADER for #{config.name}"
  end
  project.save
  puts "Project saved."
else
  puts "Target 'iOS-Objc' not found!"
end
