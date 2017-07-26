import PackageDescription

let package = Package(
    name: "Nicogram",
    targets: [
        Target(name: "NicoNico"),
        Target(
            name: "Nicogram",
            dependencies: ["NicoNico"]
        )
    ]
)
