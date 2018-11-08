release-check:
	swift build -c release
	swift test
	xcodebuild build -scheme Simulator -project Simulator-Carthage.xcodeproj