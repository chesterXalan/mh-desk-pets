// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "DeskPets",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "DeskPets", targets: ["DeskPets"]),
        .executable(name: "deskpets-hook", targets: ["DeskPetsHook"]),
    ],
    dependencies: [.package(path: "vendor/agent-session-bridge")],
    targets: [
        .target(name: "DeskPetsCore", dependencies: [
            .product(name: "AgentSessionCore", package: "agent-session-bridge"),
        ]),
        .executableTarget(name: "DeskPets", dependencies: ["DeskPetsCore"]),
        .executableTarget(name: "DeskPetsHook", dependencies: ["DeskPetsCore"]),
        .testTarget(name: "DeskPetsCoreTests", dependencies: ["DeskPetsCore"]),
        .testTarget(name: "DeskPetsTests", dependencies: ["DeskPets", "DeskPetsCore"]),
    ],
    swiftLanguageModes: [.v5]
)
