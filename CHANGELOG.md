# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [0.4.0] - 2015-09-15
### Added
- The ability to register to GCM from Android.

## [0.3.0] - 2016-08-28
### Added
- Returns a promise for GCM registration token from `registerToken`

## [0.2.0] - 2016-05-06
### Added
- Now supported by `rnpm`.
- A troubleshooting section in the README
- You can unregister a token both from subscriptions and push
  notifications altogether.

### Changed
- registration method name, to better describe what's going on. changed
  from `registerUser(..., ...)` to `registerToken(..., ...)`

## [0.1.0] - 2016-05-05
This is the first version of this module.
### Added
- The ability to register to GCM from iOS without cluttering
  `AppDelegate.m`
