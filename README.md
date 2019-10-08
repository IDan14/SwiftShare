# SwiftShare - Cocoa Touch Framework & CocoaPod
[![Podspec](https://img.shields.io/badge/private%20pod-0.1.1-blueviolet.svg?logo=gitlab)](SwiftShare.podspec)
[![Platform](https://img.shields.io/badge/platform-iOS%2010%2B-black.svg)](SwiftShare.podspec)
[![Language](https://img.shields.io/badge/language-Swift%205.1-orange.svg?logo=swift)](https://swift.org/)
[![Xcode](https://img.shields.io/badge/Xcode-11%2B-blue.svg?logo=xcode)](https://developer.apple.com/xcode)

## Requirements:
* Xcode 11+
* Swift 5.1+
* CocoaPods 1.8+

Project uses following libraries (as cocoa pods):
* [RxSwift](https://github.com/ReactiveX/RxSwift)
* [Alamofire](https://github.com/Alamofire/Alamofire) (networking)
* [SwiftyBeaver](https://github.com/SwiftyBeaver/SwiftyBeaver) (logging)
* [SwiftLint](https://github.com/realm/SwiftLint) (coding styles and conventions)

## Instalation
To add it in your Xcode project using [CocoaPods](https://cocoapods.org), specify it in you Podfile. You may use:
* local path:
```ruby
pod 'SwiftShare', :path => '~/SwiftShare'
```
* git repository address:
```ruby
pod 'SwiftShare', :git => 'https://.../SwiftShare.git', :tag => '0.1.1'
```
* private specs repository:
```ruby
source 'https://.../specs-repo.git'
source 'https://github.com/CocoaPods/Specs.git'

    target '<YOUR_APP>' do
        pod 'SwiftShare', '~> 0.1.1'
    end
```

## Framework project contains the following functionalities:

### Common types
* [AppDataError](SwiftShare/AppDataError.swift) - enum defining common error types
* [ChangeType](SwiftShare/ChangeType.swift) - enum defining functions of CRUD: create, replace, update, delete
* [HTTPStatusCodes](SwiftShare/HTTPStatusCodes.swift) - enum defining common HTTP status codes

### Caching
* [Storage](SwiftShare/Storage.swift) - generic class for saving and loading a `Codable` object to / from a file.
* [CacheBaseManager](SwiftShare/CacheBaseManager.swift) - potential base manager class for caching (uses [Storage](SwiftShare/Storage.swift) class).

### Keychain data management - from [GenericKeychain - Apple sample code](https://developer.apple.com/library/archive/samplecode/GenericKeychain/Introduction/Intro.html#//apple_ref/doc/uid/DTS40007797-Intro-DontLinkElementID_2)
* [KeychainPasswordItem](SwiftShare/KeychainPasswordItem.swift) - A struct for accessing generic password keychain items.
* [KeychainConfiguration](SwiftShare/KeychainConfiguration.swift) - A simple struct that defines the service and access group to be used by multiple apps.

### Networking
* [NetworkBaseManager](SwiftShare/NetworkBaseManager.swift) - base manager class providing Rx sequences for network operations.
* [NetworkReachabilityAlerter](SwiftShare/NetworkReachabilityAlerter.swift) - logs and displays alerts about network status changes.

### Logging
* [UtilityLogging](SwiftShare/UtilityLogging.swift) - methods for setting up Swifty Beaver console & file logger.
