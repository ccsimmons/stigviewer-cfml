component {

  /**
   * Print module version.
   */
  function run() {
    var ver = "0.8.0";
    // Best-effort read from box.json (no try/catch; only read if file exists)
    var boxPath = expandPath( "/modules/stigviewer-cfml/box.json" );
    if ( fileExists( boxPath ) ) {
      var raw = fileRead( boxPath, "utf-8" );
      var m = reFindNoCase( '"version"\s*:\s*"([^"]+)"', raw, 1, true );
      if ( m.len[1] ) {
        ver = mid( raw, m.pos[2], m.len[2] );
      }
    }
    print.line( ver );
  }

}
