component {

  property name="stigService" inject="StigService@stigviewer-cfml";

  /**
   * Export STIG rules to JSON.
   *
   * {xml} Path to XCCDF XML
   * --out Output file path (default: report.json in the current directory; falls back next to the XML if not writable)
   * --severity Comma-delimited severities or CATs:
   *            high,medium,low,unknown, cat1,cat2,cat3
   */
  function run(
    required string xml,
    string maybeSeverity = "",
    string out = "",
    string severity = "",
    string sev = "",
    string cat = ""
  ) {

    var xmlAbs = resolvePath( arguments.xml );
    var xmlDir = getDirectoryFromPath( xmlAbs );

    // Severity filter (supports --severity value, --severity=value, and CAT aliases)
    var rawSev = _pickSeverityValue( arguments, arguments.maybeSeverity );

    // If out looks like a severity token and we still don't have a severity value, treat it as severity and let output default.
    if ( !len( trim( rawSev & "" ) ) && listFindNoCase( "high,medium,low,unknown,cat1,cat2,cat3,cati,catii,catiii", trim( arguments.out & "" ) ) ) {
      rawSev = arguments.out;
      arguments.out = "";
    }

    // Default output filename (current working directory)
    if ( !len( trim( arguments.out & "" ) ) ) {
      arguments.out = "report.json";
    }

    var payload = stigService.exportXccdfJson( xmlAbs, rawSev );
    var target = resolvePath( arguments.out );

    // Try current working directory target first
    try {
      directoryCreate( getDirectoryFromPath( target ), true, true );
      fileWrite( target, payload, "utf-8" );
    } catch ( any e1 ) {

      // Fall back to the same directory as the input XML
      try {
        target = xmlDir & listLast( target, "/" );
        directoryCreate( getDirectoryFromPath( target ), true, true );
        fileWrite( target, payload, "utf-8" );
      } catch ( any e2 ) {

        // Final fall back to user home directory
        var home = getSystemSetting( "user.home" );
        if ( right( home, 1 ) != "/" ) home &= "/";
        target = home & listLast( target, "/" );
        directoryCreate( getDirectoryFromPath( target ), true, true );
        fileWrite( target, payload, "utf-8" );

      }

    }

    print.greenLine( "Wrote: #target#" );}

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
    if ( lcase( trim( raw ) ) == "true" || lcase( trim( raw ) ) == "false" ) raw = "";

    if ( !len( trim( raw ) ) && structKeyExists( args, "sev" ) ) raw = args.sev & "";
    if ( !len( trim( raw ) ) && structKeyExists( args, "cat" ) ) raw = args.cat & "";

    if ( !len( trim( raw ) ) ) raw = _extractSeverityFromArgumentKeys( args );
    if ( !len( trim( raw ) ) && len( trim( positional & "" ) ) ) raw = positional & "";

    return raw;
  }

}
