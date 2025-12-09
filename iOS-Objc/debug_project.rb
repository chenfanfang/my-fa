require 'xcodeproj'

project_path = 'iOS-Objc/iOS-Objc.xcodeproj'
project = Xcodeproj::Project.open(project_path)

def list_groups(group, indent = "")
  puts "#{indent}#{group.display_name} (#{group.path})"
  group.children.each do |child|
    if child.isa == 'PBXGroup'
      list_groups(child, indent + "  ")
    end
  end
end

list_groups(project.main_group)
