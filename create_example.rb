##!/usr/bin/env ruby

def create_example(name)
  project_name = "Example_#{name}"

  # create exmaple
  `mkdir #{project_name}`
  `cp -R ./Template/ ./#{project_name}`
  `touch ./#{project_name}/Podfile`
  File.open("./#{project_name}/Podfile", 'w') do |file|
    content = "use_frameworks!

platform :ios, '10.0'

target 'Template' do

end
"
    file.puts content
  end

  # replace internal project settings
  string_replacements = {
    'Template' => project_name
  }

  Dir.glob("./#{project_name}/**/**/**/**").each do |name|
    next if Dir.exists? name
    text = File.read(name)

    string_replacements.each do |find, replace|
      text = text.gsub(find, replace)
    end

    File.open(name, 'w') { |file| file.puts text }
  end

  # rename files
  File.rename("./#{project_name}/TemplateTests/TemplateTests.swift", "./#{project_name}/TemplateTests/#{project_name}Tests.swift")
  File.rename("./#{project_name}/TemplateUITests/TemplateUITests.swift", "./#{project_name}/TemplateUITests/#{project_name}UITests.swift")

  # rename xcodeproj
  File.rename("./#{project_name}/Template.xcodeproj", "./#{project_name}/#{project_name}.xcodeproj")

  # rename project folder
  File.rename("./#{project_name}/Template", "./#{project_name}/#{project_name}")
  File.rename("./#{project_name}/TemplateTests", "./#{project_name}/#{project_name}Tests")
  File.rename("./#{project_name}/TemplateUITests", "./#{project_name}/#{project_name}UITests")

  Dir.chdir(project_name) do
    system "pod install"
    system "open ./#{project_name}.xcworkspace"
  end

end

example_name = ARGV.shift
create_example(example_name)