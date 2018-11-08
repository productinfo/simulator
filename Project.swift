import ProjectDescription

let project = Project(name: "Simulator-Carthage",
                      targets: [
                        Target(name: "Simulator",
                               platform: .macOS,
                               product: .framework,
                               bundleId: "io.tuist.Simulator",
                               infoPlist: "Info.plist",
                               sources: "Sources/Simulator/**",
                               dependencies: [
                                    .framework(path: "Carthage/Build/Mac/SwiftShell.framework")
                               ])]
)