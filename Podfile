source 'https://github.com/CocoaPods/Specs.git'
platform :osx, '10.10'
use_frameworks!

workspace 'Maria.xcworkspace'

project 'Maria.xcodeproj'
project 'Aria2.xcodeproj'

def shared_pods
    pod 'Starscream', :git => 'https://github.com/daltoniam/Starscream.git', :branch => 'swift3'
#    pod 'SwiftyJSON', :git => 'https://github.com/SwiftyJSON/SwiftyJSON.git', :branch => 'swift3'
    pod 'SwiftyJSON', :git => 'https://github.com/BaiduHiDeviOS/SwiftyJSON.git', :branch => 'swift3'
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
    shared_pods
end
