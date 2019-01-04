release-check:
	swift build
	swift test
	xcodebuild build -scheme Simulator -project Simulator-Carthage.xcodeproj
pod-push:
	bundle exec pod trunk push --allow-warnings --verbose Simulator.podspec
carthage-archive:
	carthage build --no-skip-current --platform macOS
	carthage archive Simulator