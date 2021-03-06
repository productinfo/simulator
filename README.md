# 📱 Simulator

A simctl wrapper in Swift.

[![code style: prettier](https://img.shields.io/badge/code_style-prettier-ff69b4.svg?style=flat-square)](https://github.com/prettier/prettier)
[![CircleCI](https://circleci.com/gh/tuist/simulator.svg?style=svg)](https://circleci.com/gh/tuist/simulator)
[![codecov](https://codecov.io/gh/tuist/simulator/branch/master/graph/badge.svg)](https://codecov.io/gh/tuist/simulator)
[![Slack](http://slack.tuist.io/badge.svg)](http://slack.tuist.io)
[![FOSSA Status](https://app.fossa.io/api/projects/git%2Bgithub.com%2Ftuist%2Fsimulator.svg?type=shield)](https://app.fossa.io/projects/git%2Bgithub.com%2Ftuist%2Fsimulator?ref=badge_shield)

## Install 🛠

### Using CocoaPods

Add the following line to your `Podfile` and run `pod install`:

```ruby
pod "Simulator", "~> 1.0.0"
```

### Using Swift Package Manager

Add the following dependency to your `Package.swift`:

```swift
.package(url: "https://github.com/tuist/simulator.git", .upToNextMinor(from: "1.0.0")),
```

### Using Carthage

Add the following line to your `Cartfile` and link the `Simulator.framework` from the project:

```ruby
github "tuist/simulator" ~> 1.0.0
```

> Note: Simulator is only compatible with macOS

### Using Marathon

If you want to use Simulator in a [Marathon](https://github.com/johnsundell/marathon) script, either add it to your `Marathonfile` (see the Marathon repo for instructions on how to do that), or point Marathon to Simulator using the inline dependency syntax:

```swift
import Simulator // https://github.com/tuist/simulator.git
```

## Usage 🚀

**Devices**

```swift
// List devices
let devices = try Device.list

// Launch simulator
try device.launch()

// Wait until the simulator is launched
try device.wait(until: { $0.isBooted })

// Install an app
let appPath = URL(fileURLWithPath: "/path/App.app")
try device.install(appPath)

// Uninstall an app
try device.uninstall("io.tuist.App")

// Erase the device content
try device.erase()

// Get device runtime
let runtime = try device.runtime()
let runtimeVersion = runtime.version
```

**Runtimes**

```swift
// List runtimes
let runtimes = try Runtime.list

// Get the latest runtime
let latestiOS = try Runtime.latest(platform: .iOS)
```

## Setup for development 👩‍💻

1.  Git clone: `git@github.com:tuist/simulator.git`
2.  Generate Xcode project with `swift package generate-xcodeproj`.
3.  Open `Simulator.xcodeproj`.
4.  Have fun 🤖

## Open source

Tuist is a proud supporter of the [Software Freedom Conservacy](https://sfconservancy.org/)

<a href="https://sfconservancy.org/supporter/"><img src="https://sfconservancy.org/img/supporter-badge.png" width="194" height="90" alt="Become a Conservancy Supporter!" border="0"/></a>

## License

[![FOSSA Status](https://app.fossa.io/api/projects/git%2Bgithub.com%2Ftuist%2Fsimulator.svg?type=large)](https://app.fossa.io/projects/git%2Bgithub.com%2Ftuist%2Fsimulator?ref=badge_large)
