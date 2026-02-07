
component {

  this.title       = "StigViewer CFML";
  this.author      = "Chris Simmons (csimmons.dev)";
  this.description = "StigViewer CFML – Read and render DISA STIG XCCDF content";
  this.version     = "0.8.1";

  function configure() {
    binder.map( "StigService@stigviewer-cfml" )
      .to( "#moduleMapping#.models.StigService" );

    binder.map( "XCCDFParser@stigviewer-cfml" )
      .to( "#moduleMapping#.models.parsers.XCCDFParser" );

    binder.map( "BasicHtmlRenderer@stigviewer-cfml" )
      .to( "#moduleMapping#.models.renderers.BasicHtmlRenderer" );

    binder.map( "XSLTRenderer@stigviewer-cfml" )
      .to( "#moduleMapping#.models.xslt.XSLTRenderer" );
  }

}
