component {

  property name="stigService" inject="StigService@stigviewer-cfml";
  /**
   * Print a high-level summary of an XCCDF STIG.
   *
   * {path} Path to XCCDF XML
   * --severity Comma-delimited severities or CATs:
   *            high,medium,low,unknown, cat1,cat2,cat3
   */

  function run(
    required string xml,
    string maybeSeverity = "",
    string severity = "",
    string sev = "",
    string cat = ""
  ) {
    try {
      var xmlAbs = resolvePath( arguments.xml );
      var rawSev = _pickSeverityValue( arguments, arguments.maybeSeverity );

      var result = stigService.readXccdfSummary(
        path           = xmlAbs,
        severityFilter = rawSev
      );

      print.boldLine( result.title );
      print.line( "Version: #result.version#" );
      print.line( "" );
      print.line( "Total rules: #result.totalRules#" );
      print.line( "Matched rules: #result.matchedRules#" );
      print.line( "" );
      print.line( "Severity counts (matched set):" );
      print.line( "  HIGH: #result.counts.HIGH#" );
      print.line( "  MEDIUM: #result.counts.MEDIUM#" );
      print.line( "  LOW: #result.counts.LOW#" );
      print.line( "  UNKNOWN: #result.counts.UNKNOWN#" );
    } catch ( any e ) {
      if ( structKeyExists( e, "type" ) && findNoCase( "FileNotFound", e.type & "" ) ) {
        print.redLine( "ERROR: File not found: " & arguments.xml );
        print.line( "Tip: check the filename and path" );
        setExitCode( 1 );
        return;
      }
      rethrow;
    }
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

  private string function _pickSeverityValue( required struct args, string positional = "" ) {
    var raw = "";
    if ( structKeyExists( args, "severity" ) ) raw = args.severity & "";
    
    if ( lcase( trim( raw ) ) == "true" || lcase( trim( raw ) ) == "false" ) raw = "";if ( !len( trim( raw ) ) && structKeyExists( args, "sev" ) ) raw = args.sev & "";
    if ( !len( trim( raw ) ) && structKeyExists( args, "cat" ) ) raw = args.cat & "";
    if ( !len( trim( raw ) ) ) raw = _extractSeverityFromArgumentKeys( args );
    if ( !len( trim( raw ) ) && len( trim( positional & "" ) ) ) raw = positional & "";
    return raw;
  }
}
