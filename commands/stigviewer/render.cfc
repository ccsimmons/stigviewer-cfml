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
  function run( required string xml ) {

    var xmlAbs = resolvePath( arguments.xml );
    var xmlDir = getDirectoryFromPath( xmlAbs );

    var rawSev = structKeyExists( arguments, "severity" ) ? ( arguments.severity & "" ) : "";
    if ( !len( trim( rawSev ) ) ) rawSev = _extractSeverityFromArgumentKeys( arguments );

    var sevList = _normalizeSeverityList( rawSev );

    // Output defaults next to the input XML (avoids read-only CWD surprises)
    // Output path selection
    var outPath = "";
    if ( structKeyExists( arguments, "out" ) && len( trim( arguments.out & "" ) ) ) {
      outPath = arguments.out & "";
    } else {
      // Prefer the current shell working directory when writable; otherwise fall back to XML directory; then user home.
      var pwd = getSystemSetting( "user.dir" );
      var home = getSystemSetting( "user.home" );

      var File = createObject( "java", "java.io.File" );

      if ( File.init( pwd ).canWrite() ) {
        outPath = pwd & ( right( pwd, 1 ) == "/" ? "" : "/" ) & "report.html";
      } else if ( File.init( xmlDir ).canWrite() ) {
        outPath = xmlDir & "report.html";
      } else {
        outPath = home & ( right( home, 1 ) == "/" ? "" : "/" ) & "report.html";
      }
    }

    var target = resolvePath( outPath );
var doXslt = ( structKeyExists( arguments, "xslt" ) && isBoolean( arguments.xslt ) && arguments.xslt ) || ( structKeyExists( arguments, "xsl" ) && len( trim( arguments.xsl & "" ) ) );
    var html = "";

    if ( doXslt ) {
      var xslPath = ( structKeyExists( arguments, "xsl" ) ? ( arguments.xsl & "" ) : "" );

      // If XSL not provided, try STIG_unclass.xsl next to the XML
      if ( !len( trim( xslPath ) ) ) {
        var guess = xmlDir & "STIG_unclass.xsl";
        if ( fileExists( guess ) ) {
          xslPath = guess;
        } else {
          // Fall back silently to built-in renderer
          html = stigService.renderXccdfBasicHtml( xmlAbs, sevList, len( trim( rawSev & "" ) ) ? rawSev : "none" );
        }
      }

      if ( !len( html ) && len( trim( xslPath ) ) ) {
        // Attempt XSLT; if it fails, fall back to built-in renderer
        html = stigService.renderXccdfWithXsl( xmlPath=xmlAbs, xslPath=resolvePath( xslPath ) );
        if ( !len( trim( html ) ) ) {
          html = stigService.renderXccdfBasicHtml( xmlAbs, sevList, len( trim( rawSev & "" ) ) ? rawSev : "none" );
        }
      }
    } else {
      html = stigService.renderXccdfBasicHtml( xmlAbs, sevList, len( trim( rawSev & "" ) ) ? rawSev : "none" );
    }

    directoryCreate( getDirectoryFromPath( target ), true, true );
    fileWrite( target, html, "utf-8" );

    print.greenLine( "Wrote: #target#" );
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
