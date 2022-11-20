##!/usr/bin/env ruby

def main
    file_path = './Example_RegisterationTime/Example_RegisterationTime/Test.swift'
    
    string = "import Foundation\n\nprotocol RegisterService { \n\tstatic func registerService() \n}\n"
    (0..1000).each do |i|
        string += "class TestModel#{i}: RegisterService {\n\tinit() {}\n\tstatic func registerService() {}\n}\n"
    end
    
    file = File.new(file_path, 'w+')
    file.syswrite(string)
    
    file_path = './Example_RegisterationTime/Example_RegisterationTime/Awake.swift'
    string = "import Foundation\n\nclass Awake {}\n\n"
    (0..1000).each do |i|
        string += "extension Awake {\n\t@objc static func awakeMethod#{i}() {}\n}\n\n"
    end
    # string += "\n}"
    
    file = File.new(file_path, 'w+')
    file.syswrite(string)
end

main
