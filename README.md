# StigViewer CFML

A CommandBox module for inspecting and reporting on DISA STIG XCCDF
checklists directly from the CLI.

StigViewer CFML lets you work with STIGs on macOS, Linux, or servers
where the official DISA STIG Viewer is unavailable. You can summarize
vulnerabilities, filter findings by severity or CAT level, export rule
data to JSON, and generate readable HTML reports without leaving the
terminal.

The built-in HTML renderer is the primary supported output. StigViewer
CFML can optionally attempt to use DISA XSL stylesheets (such as
`STIG_unclass.xsl`), but modern Java runtimes often block the legacy
XSLT engine required by those stylesheets. When that occurs, the module
automatically falls back to the built-in renderer.

------------------------------------------------------------------------

## Commands

-   `stigviewer summary` -- summarize STIG rules and severities
-   `stigviewer export` -- export rules to JSON
-   `stigviewer render` -- generate an HTML report
-   `stigviewer version`
-   `stigviewer about`

------------------------------------------------------------------------

## Summarize a STIG

    stigviewer summary U_Adobe_ColdFusion_STIG_V1R1_Manual-xccdf.xml

### Filter by severity

    stigviewer summary file.xml --severity=high,medium

### Filter by STIG category (CAT)

    stigviewer summary file.xml --severity=cat1,cat2

### Severity mappings

-   CAT I → high
-   CAT II → medium
-   CAT III → low

Supported flag forms:

    --severity=medium
    --severity medium
    -severity=medium

------------------------------------------------------------------------

## Export rules to JSON

Export all rules:

    stigviewer export file.xml --out=cf-stig.json

Export only CAT I:

    stigviewer export file.xml --severity=cat1 --out=cf-stig-cat1.json

### JSON Output Includes

-   `TOTALRULECOUNT`
-   `MATCHEDRECORDCOUNT`
-   `SEVERITYFILTER` (or `none`)
-   `RULES`

------------------------------------------------------------------------

## Render HTML Report

Default rendering (recommended):

    stigviewer render file.xml

Default output:

    report.html

### Optional XSLT Rendering

To attempt rendering with the official DISA stylesheet:

    stigviewer render file.xml --xsl=STIG_unclass.xsl

If `STIG_unclass.xsl` is located in the same directory as the XML, the
module will automatically attempt to use it when requested.

> Note: On modern Java versions the DISA XSLT engine is often blocked.
> When this happens StigViewer CFML automatically falls back to the
> built-in renderer and still produces a complete report.

------------------------------------------------------------------------

## Defaults

-   `stigviewer export` → `report.json`
-   `stigviewer render` → `report.html`

Both write to a writable directory unless `--out` is specified.

------------------------------------------------------------------------

## Severity Filtering

`summary`, `export`, and `render` all support severity filtering.

Accepted values:

    high, medium, low, unknown
    cat1, cat2, cat3

------------------------------------------------------------------------

## STIG Downloads

Official DISA STIG XCCDF files: https://www.cyber.mil/stigs/downloads/

------------------------------------------------------------------------

## License

Apache 2.0 --- see `LICENSE`.

------------------------------------------------------------------------

## Changelog

See [CHANGELOG.md](CHANGELOG.md)
