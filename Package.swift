import PackageDescription

let package = Package(
    name: "Nicogram",
    targets: [
        Target(name: "NicoNicoKit"),
        Target(
            name: "Nicogram",
            dependencies: ["NicoNicoKit"]
        )
    ]
)
