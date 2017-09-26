# Changelog
All notable changes to this project will be documented in this file.

This project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Changed
- Line breaking procedure in paragraphing is updated again.

## [0.0.4] -- 2017-09-02
### Added
- Support for indication of *lacunas* with `<gap type="lacuna">`. No support for
  extent or critical notes yet.

### Changed
- The latex preamble no longer outputs full directory path of the conversion
  document.

## [0.0.3] -- 2017-08-18
### Fixed
- Make sure input to `my:format-lemma` is string when instantiating
  `$lemma_text` variable.

## [0.0.2] -- 2017-08-15
### Added
- Add very simple handling of <note> elements. They are converted into
  `\footnote{}`s.
- Make it possible to configure the structural level (e.g. `chapter` or
  `section`) in headings created from `<head>` elements.

### Changed
- `<unclear>` in readings is handled within the reading templates and the text
  is changed from "ut vid." to "lectio incerta".
- `@type = 'conjecture-corrected'` is phrased differently to accommodate
  conjectures by the current editor that are not included in the main text.
- Improved handling of empty lemmata.
- Change handling of structure numberings and add documentation.
- Linebreaks in paragraph construction has been improved.
- Change presentation of header and how draft text are marked (now with
  watermark) to better accommodate long titles in the header.

### Fixed
- Identity test between lemma text and reading content should call current
  context `<rdg>` not a child `<rdg>`.

## [0.0.1] -- 2017-08-04
### Added
- This is the first numbered version of the scripts and thus the first versioned
  release. The scripts have been under development since July 17 2016
  (2016-07-17).
- Draft capabilities of converting Lombard Press Schema compatible XML files to
  TeX. The versions of the LBP schema that it currently supports are 0.0.0
  (partial support), and 1.0.0 which aims at (but does not yet provide) complete
  support.
