component {

  property name="xccdfParser" inject="XCCDFParser@stigviewer-cfml";
  property name="basicHtmlRenderer" inject="BasicHtmlRenderer@stigviewer-cfml";
  property name="xsltRenderer" inject="XSLTRenderer@stigviewer-cfml";

  function readXccdfSummary( required string path, string severityFilter = "" ) {

    // Validate input path early for a cleaner CLI error
    if ( !fileExists( arguments.path ) ) {
      throw(
        type    = "StigViewer.readXccdfSummary.FileNotFound",
        message = "XCCDF file not found: " & arguments.path
      );
    }

    var xmlStr = fileRead( arguments.path, "utf-8" );
    var parser = variables.xccdfParser;

    var sevList = _normalizeSeverityList( arguments.severityFilter );
    var meta = parser.summary( xmlStr, arguments.path, sevList );

    // Normalize counts to UPPERCASE keys for display
    var counts = { HIGH=0, MEDIUM=0, LOW=0, UNKNOWN=0 };
    if ( structKeyExists( meta, "severityCounts" ) && isStruct( meta.severityCounts ) ) {
      if ( structKeyExists( meta.severityCounts, "high" ) ) counts.HIGH = meta.severityCounts.high;
      if ( structKeyExists( meta.severityCounts, "medium" ) ) counts.MEDIUM = meta.severityCounts.medium;
      if ( structKeyExists( meta.severityCounts, "low" ) ) counts.LOW = meta.severityCounts.low;
      if ( structKeyExists( meta.severityCounts, "unknown" ) ) counts.UNKNOWN = meta.severityCounts.unknown;
    }

    return {
      title        : meta.title,
      version      : meta.version,
      totalRules   : meta.totalRuleCount,
      matchedRules : meta.filteredRuleCount,
      counts       : counts
    };
  }

  function exportXccdfJson( required string path, string severityFilter = "" ) {

    // Validate input path early for a cleaner CLI error
    if ( !fileExists( arguments.path ) ) {
      throw(
        type    = "StigViewer.exportXccdfJson.FileNotFound",
        message = "XCCDF file not found: " & arguments.path
      );
    }

    var xmlStr = fileRead( arguments.path, "utf-8" );
    var parser = variables.xccdfParser;

    var sevList = _normalizeSeverityList( arguments.severityFilter );
    var data = parser.rules( xmlStr, arguments.path, sevList );

    var payload = {
      "TOTALRULECOUNT"     : data.totalRuleCount,
      "MATCHEDRECORDCOUNT" : arrayLen( data.rules ),
      "SEVERITYFILTER"     : len( trim( arguments.severityFilter & "" ) ) ? arguments.severityFilter : "none",
      "RULES"              : data.rules
    };

    return serializeJSON( payload );
  }

  function renderXccdfBasicHtml(
    required string path,
    array severities = [],
    string severityFilter = "none"
  ) {

    // Validate input path early for a cleaner CLI error
    if ( !fileExists( arguments.path ) ) {
      throw(
        type    = "StigViewer.renderXccdfBasicHtml.FileNotFound",
        message = "XCCDF file not found: " & arguments.path
      );
    }

    var xmlStr = fileRead( arguments.path, "utf-8" );
    var parser = variables.xccdfParser;

    var meta = parser.summary( xmlStr, arguments.path );

    meta.severityFilter     = len( trim( arguments.severityFilter & "" ) ) ? arguments.severityFilter : "none";
    meta.generatedOnDate    = dateFormat( now(), "mm/dd/yyyy" );
    meta.generatedOnTime    = timeFormat( now(), "hh:mm:ss tt" );
    meta.stigViewerVersion  = "0.8.0";

    var data = parser.rules( xmlStr, arguments.path, arguments.severities );
    meta.matchedRecordCount = arrayLen( data.rules );

    return variables.basicHtmlRenderer.render( meta, data );
  }

  function renderXccdfWithXsl( required string xmlPath, required string xslPath ) {
    // Best-effort; return empty string on failure so callers can fall back.
    try {
      if ( fileExists( arguments.xmlPath ) && fileExists( arguments.xslPath ) ) {
        return variables.xsltRenderer.renderToHtml( arguments.xmlPath, arguments.xslPath );
      }
    } catch ( any e ) {
      // ignore; caller will fall back
    }
    return "";
  }

  private array function _normalizeSeverityList( any s ) {
    var out = [];

    if ( isArray( s ) ) s = arrayToList( s );
    if ( isNull( s ) || !len( trim( s & "" ) ) ) return out;

    for ( var item in listToArray( lcase( s ) ) ) {
      var v = trim( item );
      if ( !len( v ) ) continue;

      v = replace( v, " ", "", "all" );
      v = replace( v, "-", "", "all" );
      v = replace( v, "_", "", "all" );

      if ( v == "cat1" || v == "cati" ) v = "high";
      else if ( v == "cat2" || v == "catii" ) v = "medium";
      else if ( v == "cat3" || v == "catiii" ) v = "low";

      if ( listFindNoCase( "high,medium,low,unknown", v ) ) {
        if ( !arrayFindNoCase( out, v ) ) arrayAppend( out, v );
      }
    }

    return out;
  }

}
