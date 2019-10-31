# SwiftShare - Cocoa Touch Framework & CocoaPod
[![Podspec](https://img.shields.io/badge/private%20pod-0.1.2-blueviolet.svg?logo=gitlab)](SwiftShare.podspec)
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
pod 'SwiftShare', :git => 'https://.../SwiftShare.git', :tag => '0.1.2'
```
* private specs repository:
```ruby
source 'https://.../specs-repo.git'
source 'https://github.com/CocoaPods/Specs.git'

    target '<YOUR_APP>' do
        pod 'SwiftShare', '~> 0.1.2'
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

### Extensions
* [UIContentSizeCategory](SwiftShare/Extensions/UIContentSizeCategory+.swift) - numeric values corresponding to each defined content category size
* [UIImage](SwiftShare/Extensions/UIImage+.swift) - create image of specific color & size
* [UITextField](SwiftShare/Extensions/UITextField+.swift) - method for chaining an array of text fields objects (on clicking return key relinquish first responder status to next item)
* [UIView](SwiftShare/Extensions/UIView+.swift) - load view from nib
* [UIViewController](SwiftShare/Extensions/UIViewController+.swift) - display alert (with message, title, completion and click handlers)
* [UNNotificationAttachment](SwiftShare/Extensions/UNNotificationAttachment+.swift) - create notification attachment (with file identifier and data)
* [UtilityExtensions](SwiftShare/Extensions/UtilityExtensions.swift) - extensions for String, CustomStringConvertible, CustomDebugStringConvertible, NSAttributedString, NSMutableAttributedString

### UI
* [PostComposer](SwiftShare/UI/PostComposer.swift) - Post messages using supported social networking services (facebook, twitter, linkedin, whatsapp) or mail. Does NOT use any 3rd party frameworks.
* [ScrollableInputHandler](SwiftShare/UI/ScrollableInputHandler.swift) - Helper class (for a view or view controller) for automatically scrolling text fields above on-screen keyboard.
* [SegueGoLeftToRight](SwiftShare/UI/SegueGoLeftToRight.swift)
* [VerticallyCenteredTextView](SwiftShare/UI/VerticallyCenteredTextView.swift)
* [UICollectionViewLeftAlignedFlowLayout](SwiftShare/UI/UICollectionViewLeftAlignedFlowLayout.swift)
* [UtilityToolkit](SwiftShare/UI/UtilityToolkit.swift) - init WKWebView on iOS10; list installed fonts.

### ViewControllers
* [MonthYearPickerViewController](SwiftShare/ViewControllers/MonthYearPickerViewController.swift) - Date picker variant without day of the month.
* [SimpleBaseViewController](SwiftShare/ViewControllers/SimpleBaseViewController.swift) - Base class for a view controller showing a main view and a row of buttons. Used for programmatically created modals / pop-ups.
* [SimpleTextViewController](SwiftShare/ViewControllers/SimpleTextViewController.swift) - Extends [SimpleBaseViewController](SwiftShare/ViewControllers/SimpleBaseViewController.swift) and uses a TextView as main view.
* [SimpleWebViewController](SwiftShare/ViewControllers/SimpleWebViewController.swift) - Extends [SimpleBaseViewController](SwiftShare/ViewControllers/SimpleBaseViewController.swift) and uses a WKWebView as main view.
* [SlideMenuViewController](SwiftShare/ViewControllers/SlideMenuViewController.swift) - Base class for a sliding menu (left or right side hamburger menu).

### App Version Checker
* [AppVersionChecker](SwiftShare/AppVersionChecker/AppVersionChecker.swift) - determines version status (see documentation for method check).
* [UpdateOverlay](SwiftShare/AppVersionChecker/UpdateOverlay.swift) - displays pop-up with update message and options (based on version status).
* [VersionStatus](SwiftShare/AppVersionChecker/VersionStatus.swift) - enum defining installed version status (in relation to available update).
* [VersionData](SwiftShare/AppVersionChecker/VersionData.swift) - object describing update information (usually provided by server).
