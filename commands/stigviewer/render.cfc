component {

  property name="stigService" inject="StigService@stigviewer-cfml";
  /**
   * Render an XCCDF STIG to HTML.
   *
   * {xml} Path to XCCDF XML
   * --out Output file path (default: report.html next to the input XML)
   * --severity Comma-delimited severities or CATs:
   *            high,medium,low,unknown, cat1,cat2,cat3
   * --xsl Path to XSL file (optional; enables XSLT)
   * --xslt true/false (default false)
   */

  function run(
    required string xml,
    string maybeSeverity = "",
    string out = "",
    string severity = "",
    string sev = "",
    string cat = "",
    string xsl = "",
    boolean xslt = false
  ) {
    try {
      var xmlAbs = resolvePath( arguments.xml );
      var xmlDir = getDirectoryFromPath( xmlAbs );
      var rawSev = _pickSeverityValue( arguments, arguments.maybeSeverity );
      var sevList = _normalizeSeverityList( rawSev );

      if ( !len( trim( arguments.out & "" ) ) ) arguments.out = "report.html";

      // Built-in renderer (XSLT optional in other versions; keeping built-in default here)
      var html = stigService.renderXccdfBasicHtml( xmlAbs, sevList, len( trim( rawSev & "" ) ) ? rawSev : "none" );

      var target = resolvePath( arguments.out );
      try {
        directoryCreate( getDirectoryFromPath( target ), true, true );
        fileWrite( target, html, "utf-8" );
      } catch ( any e1 ) {
        target = xmlDir & listLast( target, "/" );
        directoryCreate( getDirectoryFromPath( target ), true, true );
        fileWrite( target, html, "utf-8" );
      }

      print.greenLine( "Wrote: #target#" );
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

  private array function _normalizeSeverityList( any s ) {
    var out = [];

    if ( isArray( s ) ) {
      s = arrayToList( s );
    }
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
    if ( !len( trim( raw ) ) && structKeyExists( args, "sev" ) ) raw = args.sev & "";
    if ( !len( trim( raw ) ) && structKeyExists( args, "cat" ) ) raw = args.cat & "";
    if ( !len( trim( raw ) ) ) raw = _extractSeverityFromArgumentKeys( args );
    if ( !len( trim( raw ) ) && len( trim( positional & "" ) ) ) raw = positional & "";
    return raw;
  }

}
