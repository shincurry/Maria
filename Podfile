source 'https://github.com/CocoaPods/Specs.git'
platform :osx, '10.10'
use_frameworks!

workspace 'Maria.xcworkspace'

project 'Maria.xcodeproj'
project 'Aria2.xcodeproj'

def starscream
    pod 'Starscream', :git => 'https://github.com/daltoniam/Starscream.git'
end

def swifty_json
    pod 'SwiftyJSON', :git => 'https://github.com/SwiftyJSON/SwiftyJSON.git'
end

def swifty_userdefaults
    pod 'SwiftyUserDefaults', :git => 'https://github.com/radex/SwiftyUserDefaults.git'
end

def shared_pods
    starscream
    swifty_json
    swifty_userdefaults
end


target 'Maria' do
    project 'Maria'
    shared_pods
end

target 'Maria Widget' do
    project 'Maria'
    shared_pods
end

target 'Aria2' do
    project 'Aria2'
    starscream
    swifty_json
end

target 'YouGet' do
    project 'YouGet'
    swifty_json
end
