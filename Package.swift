import PackageDescription

let package = Package(
    name: "Nicogram",
    targets: [
        Target(name: "NicoNicoKit"),
        Target(
            name: "NicogramCore",
            dependencies: ["NicoNicoKit"]
        ),
        Target(
            name: "Nicogram",
            dependencies: ["NicogramCore"]
        )
    ]
)
