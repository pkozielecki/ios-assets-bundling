# Efficient Assets Bundling showcase

Welcome to the demonstration of how you can enrich your application with additional content (e.g. games, video material, etc.) using a combination of **Background Assets** and **On-Demand Resources** in a **SwiftUI** project.

## Main app features
* Uses **Background Assets** framework to download large assets.
* Uses **Background Assets** Extension to pre-download the assets even if the application is not running!.
* Showcases **Essential Assets** that are downloaded with the application.
* Uses **On-Demand Resources** framework to download lightweight assets that should be bundled with the application (e.g. files containing game logics).
* Can **re-download** broken assets.
* Uses **SwiftUIRouter** component for navigation.
* Uses **Observation** framework to set up communication between views and business logic. 
* Relies on **Assets Bundling POC Commons** framework for the code shared between the app and the extension.

| ![](External%20Resources/bundler-load-assets.gif) | ![](External%20Resources/bundler-assets-preview.gif) | ![](External%20Resources/bundler-redownload-asset.gif) |
|---------------------------------------------------|---------------------------------------------------|---------------------------------|


## Integration

### Requirements
* iOS 17.0

### Running the app

* Clone the repo.
* Open `Assets Bundling POC.xcodeproj` file.
* Use `Assets Bundling POC` scheme to run the application.
* Use `Assets Downloader Extension` scheme to run the extension.

## Next steps:

* Add **Tests** to the App and the Commons framework.

## Project maintainer

- [Pawel Kozielecki](https://github.com/pkozielecki)

See also the list of [contributors](https://github.com/pkozielecki/ios-tca-showcase/graphs/contributors) who participated in this project.

## License

This project is licensed under the Apache License.
[More info](LICENSE.md)
