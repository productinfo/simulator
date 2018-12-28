release-check:
	swift build
	swift test
	xcodebuild build -scheme Simulator -project Simulator-Carthage.xcodeproj