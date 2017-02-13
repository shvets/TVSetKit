import PackageDescription

let package = Package(
  name: "TVSetKit",
  dependencies: [
    .Package(url: "../WebAPI", Version(1, 0, 0))
  ]
)
