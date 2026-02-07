component {

  property name="stigService" inject="StigService@stigviewer-cfml";

  /**
   * Print a high-level summary of an XCCDF STIG.
   *
   * {path} Path to XCCDF XML
   * --severity Comma-delimited severities or CATs:
   *            high,medium,low,unknown, cat1,cat2,cat3
   */
  function run( required string path ) {

    var xmlAbs = resolvePath( arguments.path );

    var rawSev = structKeyExists( arguments, "severity" ) ? ( arguments.severity & "" ) : "";
    if ( !len( trim( rawSev ) ) ) rawSev = _extractSeverityFromArgumentKeys( arguments );

    var data = stigService.readXccdfSummary( xmlAbs, rawSev );

    print.line( data.title );
    print.line( "Version: " & data.version );
    print.line( "" );
    print.line( "Total rules: " & data.totalRules );
    print.line( "Matched rules: " & data.matchedRules );
    print.line( "Severity Filter: " & ( len( trim( rawSev ) ) ? rawSev : "none" ) );
    print.line( "" );
    print.line( "Severity counts (matched set):" );
    print.line( "  HIGH: " & data.counts.HIGH );
    print.line( "  MEDIUM: " & data.counts.MEDIUM );
    print.line( "  LOW: " & data.counts.LOW );
    print.line( "  UNKNOWN: " & data.counts.UNKNOWN );
  }

  private string function _extractSeverityFromArgumentKeys( required struct args ) {
    for ( var k in args ) {
      var key = lcase( k & "" );
      key = rereplace( key, "^[\-]+", "", "all" );
      if ( left( key, 9 ) == "severity=" ) return mid( key, 10, len( key ) );
      if ( left( key, 4 ) == "sev=" ) return mid( key, 5, len( key ) );
      if ( left( key, 4 ) == "cat=" ) return mid( key, 5, len( key ) );
    }
    return "";
  }

}
