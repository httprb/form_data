# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [3.0.0] - 2026-03-16

### Added

- `Multipart` accepts a `content_type:` keyword to support `multipart/related`,
  `multipart/mixed`, and other multipart content types. Defaults to
  `multipart/form-data`.
  ([#1](https://github.com/httprb/form_data/issues/1))
- `FormData::File#close` for closing file handles opened from String paths or
  Pathnames. When a File is created from an existing IO, `close` is a no-op.
  ([#27](https://github.com/httprb/form_data/issues/27))
- Accept any Enumerable (not just Hash or Array) as form data input for both
  `Multipart` and `Urlencoded` encoders. This enables lazy enumerators and
  custom collections as input.
- `FormData.ensure_data` for coercing input to an Enumerable of key-value pairs.
- Array of pairs input for `Multipart`, allowing duplicate parameter names and
  preserved ordering.
- Array of pairs input for `Urlencoded`, preserving duplicate keys.
- RBS type signatures for all public and private APIs.
- `sig/` directory shipped in the gem for downstream type checking.
- `homepage_uri`, `source_code_uri`, `bug_tracker_uri`, and `documentation_uri`
  gemspec metadata.

### Changed

- Default urlencoded encoder replaced with a custom implementation that supports
  nested Hashes and Arrays (e.g., `{foo: {bar: "baz"}}` encodes as
  `foo[bar]=baz`). Previously used `URI.encode_www_form`.
- `FormData.ensure_hash` no longer treats `nil` as a special case; `nil.to_h`
  returns `{}` which is used instead.

### Removed

- Ruby < 3.2 support.
- Explicit JRuby support.
- `FormData::File#mime_type` deprecated alias. Use `#content_type` instead.
- `:mime_type` option in `FormData::File#initialize`. Use `:content_type` instead.

## [2.3.0] - 2020-03-08

### Added

- Per-instance encoder for `HTTP::FormData::Urlencoded`.
  ([#29](https://github.com/httprb/form_data/pull/29) by [@summera])

## [2.2.0] - 2020-01-09

### Fixed

- Ruby 2.7 compatibility.
  ([#28](https://github.com/httprb/form_data/pull/28) by [@janko])

## [2.1.1] - 2018-06-01

### Added

- Allow overriding urlencoded form data encoder.
  ([#23](https://github.com/httprb/form_data/pull/23) by [@FabienChaynes])

## [2.1.0] - 2018-03-05

### Fixed

- Rewind content at the end of `Readable#to_s`.
  ([#21](https://github.com/httprb/form_data/pull/21) by [@janko-m])
- Buffer encoding.
  ([#19](https://github.com/httprb/form_data/pull/19) by [@HoneyryderChuck])

## [2.0.0] - 2017-10-01

### Fixed

- Add CRLF character to end of multipart body.
  ([#17](https://github.com/httprb/form_data/pull/17) by [@mhickman])

## [2.0.0.pre2] - 2017-05-11

### Added

- Streaming for urlencoded form data.
  ([#14](https://github.com/httprb/form_data/pull/14) by [@janko-m])

## [2.0.0.pre1] - 2017-05-10

### Added

- Form data streaming.
  ([#12](https://github.com/httprb/form_data.rb/pull/12) by [@janko-m])

## [1.0.2] - 2017-05-08

### Added

- Allow setting Content-Type on non-file parts.
  ([#5](https://github.com/httprb/form_data.rb/issues/5) by [@abotalov])
- Creation of file parts without filename.
  ([#6](https://github.com/httprb/form_data.rb/issues/6) by [@abotalov])

### Deprecated

- `HTTP::FormData::File#mime_type`. Use `#content_type` instead.
  ([#11](https://github.com/httprb/form_data.rb/pull/11) by [@ixti])

## [1.0.1] - 2015-03-31

### Fixed

- Usage of URI module.

## [1.0.0] - 2015-01-04

### Changed

- Gem renamed to `http-form_data` as `FormData` is no longer a top-level
  constant: `FormData` → `HTTP::FormData`.

## [0.1.0] - 2015-01-02

### Added

- `nil` support to `FormData#ensure_hash`.

### Changed

- Moved repo under `httprb` organization on GitHub.

## [0.0.1] - 2014-12-15

### Added

- Initial release.

[3.0.0]: https://github.com/httprb/form_data/compare/v2.3.0...v3.0.0
[2.3.0]: https://github.com/httprb/form_data/compare/v2.2.0...v2.3.0
[2.2.0]: https://github.com/httprb/form_data/compare/v2.1.1...v2.2.0
[2.1.1]: https://github.com/httprb/form_data/compare/v2.1.0...v2.1.1
[2.1.0]: https://github.com/httprb/form_data/compare/v2.0.0...v2.1.0
[2.0.0]: https://github.com/httprb/form_data/compare/v2.0.0.pre2...v2.0.0
[2.0.0.pre2]: https://github.com/httprb/form_data/compare/v2.0.0.pre1...v2.0.0.pre2
[2.0.0.pre1]: https://github.com/httprb/form_data/compare/v1.0.2...v2.0.0.pre1
[1.0.2]: https://github.com/httprb/form_data/compare/v1.0.1...v1.0.2
[1.0.1]: https://github.com/httprb/form_data/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/httprb/form_data/compare/v0.1.0...v1.0.0
[0.1.0]: https://github.com/httprb/form_data/compare/v0.0.1...v0.1.0
[0.0.1]: https://github.com/httprb/form_data/releases/tag/v0.0.1

[@abotalov]: https://github.com/abotalov
[@FabienChaynes]: https://github.com/FabienChaynes
[@HoneyryderChuck]: https://github.com/HoneyryderChuck
[@ixti]: https://github.com/ixti
[@janko]: https://github.com/janko
[@janko-m]: https://github.com/janko-m
[@mhickman]: https://github.com/mhickman
[@summera]: https://github.com/summera
