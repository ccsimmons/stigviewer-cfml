component {

  /**
   * About this module.
   */
  function run() {
    print.line( "StigViewer CFML" );
    print.line( "A CommandBox module for reading, filtering, and rendering DISA STIG XCCDF content." );
    print.line( "" );
    print.line( "Commands:" );
    print.line( "  stigviewer summary <xccdf.xml> [--severity=high,medium|cat1,cat2]" );
    print.line( "  stigviewer export  <xccdf.xml> [--severity=...] [--out=output.json]" );
    print.line( "  stigviewer render  <xccdf.xml> [--xsl=STIG_unclass.xsl] [--out=report.html]" );
    print.line( "  stigviewer version" );
    print.line( "  stigviewer about" );
    print.line( "" );
    print.line( "STIGs Document Library: https://www.cyber.mil/stigs/downloads/" );
  }

}
