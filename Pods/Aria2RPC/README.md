# Aria2RPC
aria2 rpc client for Swift.

## Environment

- Swift 3+
- OS X 10.10+

## Installation

### CocoaPods

Check out [Get Started](http://cocoapods.org/) tab on [cocoapods.org](http://cocoapods.org/).

To use Aria2RPC in your project add the following 'Podfile' to your project

```Ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :osx, '10.10'
use_frameworks!

pod 'Aria2RPC', '~> 1.0.0'
```

Then run:

```Shell
pod install
```

## Method list

```Swift
open func connect()
open var onConnect: (() -> Void)?
open func disconnect()
open var onDisconnect: (() -> Void)?
open var status: Aria2RPC.ConnectionStatus { get set }
open var onStatusChanged: ((Void) -> Void)?
open func shutdown(force: Bool)
open func add(uri: String, withOptions options: [String : String]? = default)
open func add(uris: [String], withOptions options: [String : String]? = default)
open var onAddUris: ((_ flag: Bool) -> Void)?
open func getUris(_ gid: String)
open var onGetUris: ((_ results: [String]) -> Void)?
open func add(torrent: Data, withOptions options: [String : String]? = default)
open var onAddTorrent: ((_ flag: Bool) -> Void)?
open func tellActive()
open var onActives: ((_ results: [Aria2Task]?) -> Void)?
open func tellWaiting()
open var onWaitings: ((_ results: [Aria2Task]?) -> Void)?
open func tellStopped()
open var onStoppeds: ((_ results: [Aria2Task]?) -> Void)?
open func getGlobalStatus()
open var onGlobalStatus: ((_ result: Aria2GlobalStatus) -> Void)?
open func removeActive(_ gid: String)
open var onRemoveActive: ((_ flag: Bool) -> Void)?
open func removeOther(_ gid: String)
open var onRemoveOther: ((_ flag: Bool) -> Void)?
open func clearCompletedErrorRemoved()
open var onClearCompletedErrorRemoved: ((_ flag: Bool) -> Void)?
open func pause(_ gid: String)
open var onPause: ((_ flag: Bool) -> Void)?
open func pauseAll()
open var onPauseAll: ((_ flag: Bool) -> Void)?
open func unpause(_ gid: String)
open var onUnpause: ((_ flag: Bool) -> Void)?
open func unpauseAll()
open var onUnpauseAll: ((_ flag: Bool) -> Void)?
open func restart(_ task: Aria2Task) -> <<error type>>
open var onRemoveOtherToRestart: ((_ flag: Bool) -> Void)?
open var onRestart: ((_ flag: Bool) -> Void)?
open var downloadCompleted: ((_ name: String, _ folderPath: String) -> Void)?
open var downloadPaused: ((_ name: String) -> Void)?
open var downloadStarted: ((_ name: String) -> Void)?
open var downloadStopped: ((_ name: String) -> Void)?
open var downloadError: ((_ name: String) -> Void)?
open func globalSpeedLimit(download: Int, upload: Int)
open var onGlobalSpeedLimitOK: ((_ flag: Bool) -> Void)?
open func lowSpeedLimit(download: Int, upload: Int)
open var onLowSpeedLimitOK: ((_ flag: Bool) -> Void)?
open func change(globalOption options: [String : String])
open var onChangeGlobalOption: ((_ flag: Bool) -> Void)?
```