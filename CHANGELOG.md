StigViewer CFML – Changelog
==========================

## 0.8.0 – 2026-02-06
- Friendly CLI error for missing XCCDF files (prints a helpful message and exits non-zero, no stack trace).
- Improved error handling when the input XCCDF file path does not exist (clean StigViewer error instead of a raw stack trace).

## 0.7.9 – 2026-02-06
- Stabilized `stigviewer version` and `stigviewer about` commands.
- Corrected module version reporting.
- General reliability fixes and cleanup.

## 0.7.8 – 2026-02-06
- Rendered HTML report now displays:
  - Matched Record Count
  - Active Severity Filter
- Added generated footer with timestamp and StigViewer CFML version.
- `stigviewer export` JSON now includes:
  - `TOTALRULECOUNT`
  - `MATCHEDRECORDCOUNT`
  - `SEVERITYFILTER`
  - `RULES`
- Documentation updated for severity flag usage (`--severity value` and `--severity=value`).

## 0.7.4 – 2026-02-06
- Fixed severity filtering across `summary`, `export`, and `render`.
- Added support for CAT mappings:
  - CAT I → high
  - CAT II → medium
  - CAT III → low
- Resolved CommandBox argument parsing issues with severity flags.

## 0.7.2 – 2026-02-06
- Built-in HTML renderer is now the default (XSLT optional).
- Rendering no longer depends on JVM XSLT access.
- Severity filtering enabled for rendered reports.

## 0.7.0 – 2026-02-06
- Export and render now write to files by default.
- Output automatically falls back to the XML directory if the current directory is not writable.
- Improved path handling using CommandBox path resolution.

## 0.6.9 – 2026-02-06
- Default output filenames:
  - `report.html` for render
  - `report.json` for export
- Output flag handling improved.

## 0.6.5 – 2026-02-06
- Added severity filtering flags:
  - `--severity`
  - `--sev`
  - `--cat`
- Added fallback HTML rendering when XSLT is unavailable.

## 0.6.4 – 2026-02-06
- Added `stigviewer version` and `stigviewer about` commands.

## 0.5.0 – 2026-02-06
- Renamed project to **StigViewer CFML**.
- New command namespace:
  - `stigviewer summary`
  - `stigviewer export`
  - `stigviewer render`
- Implemented STIG rule parsing and filtering.
- Added CAT I/II/III severity aliases.
- Added XSLT rendering support.

## 0.4.0 – 2026-02-06
- Stabilized module loading and service injection.
- Fixed component resolution in CommandBox modules.

## 0.3.0 – 2026-02-06
- Added severity filtering and matched vs total rule counts.

## 0.2.0 – 2026-02-06
- Added initial XSL rendering support.

## 0.1.0 – 2026-02-06
- Initial proof-of-concept: basic XCCDF parsing and rule enumeration.
