# Changelog
All notable changes to this project will be documented in this file.

This project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
- Add very simple handling of <note> elements. They are converted into
  `\footnote{}`s.

### Changed
- Improved handling of empty lemmata.
- Change handling of structure numberings and add documentation.


## [0.0.1] -- 2017-08-04
### Added
- This is the first numbered version of the scripts and thus the first versioned
  release. The scripts have been under development since July 17 2016
  (2016-07-17).
- Draft capabilities of converting Lombard Press Schema compatible XML files to
  TeX. The versions of the LBP schema that it currently supports are 0.0.0
  (partial support), and 1.0.0 which aims at (but does not yet provide) complete
  support.
