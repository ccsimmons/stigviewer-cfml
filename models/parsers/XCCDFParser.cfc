
component {

  function summary( required string xmlString, string sourcePath="", array severities = [] ) {
    var doc = xmlParse( xmlString );

    var title   = _firstText( doc, "//*[local-name()='Benchmark']/*[local-name()='title']" );
    var version = _firstText( doc, "//*[local-name()='Benchmark']/*[local-name()='version']" );

    var ruleNodesAll = xmlSearch( doc, "//*[local-name()='Rule']" );
    var ruleNodes    = _filterRulesBySeverity( ruleNodesAll, severities );

    var counts = { low=0, medium=0, high=0, unknown=0 };
    for ( var r in ruleNodes ) {
      var sev = lcase( r.xmlAttributes.severity ?: "unknown" );
      if ( !structKeyExists( counts, sev ) ) counts[ sev ] = 0;
      counts[ sev ]++;
    }

    return {
      sourcePath        = sourcePath,
      title             = title,
      version           = version,
      totalRuleCount    = arrayLen( ruleNodesAll ),
      filteredRuleCount = arrayLen( ruleNodes ),
      severityCounts    = counts
    };
  }

  function rules( required string xmlString, string sourcePath="", array severities = [] ) {
    var doc = xmlParse( xmlString );
    var ruleNodesAll = xmlSearch( doc, "//*[local-name()='Rule']" );
    var ruleNodes    = _filterRulesBySeverity( ruleNodesAll, severities );

    var out = [];

    for ( var r in ruleNodes ) {
      arrayAppend( out, {
        id       = r.xmlAttributes.id ?: "",
        severity = lcase( r.xmlAttributes.severity ?: "unknown" ),
        weight   = r.xmlAttributes.weight ?: "",
        reqId    = _firstText( r, "*[local-name()='version']" ),
        title    = _firstText( r, "*[local-name()='title']" ),
        check    = _firstText( r, ".//*[local-name()='check-content']" ),
        fix      = _firstText( r, ".//*[local-name()='fixtext']" )
      } );
    }

    return {
      sourcePath     = sourcePath,
      totalRuleCount = arrayLen( ruleNodesAll ),
      rules          = out
    };
  }

  private array function _filterRulesBySeverity( required array ruleNodes, required array severities ) {
    if ( !arrayLen( severities ) ) return ruleNodes;

    var allowed = [];
    for ( var s in severities ) {
      var v = lcase( trim( s ) );
      if ( len( v ) && !arrayFindNoCase( allowed, v ) ) arrayAppend( allowed, v );
    }

    var out = [];
    for ( var r in ruleNodes ) {
      var sev = lcase( r.xmlAttributes.severity ?: "unknown" );
      if ( arrayFindNoCase( allowed, sev ) ) arrayAppend( out, r );
    }
    return out;
  }

  private string function _firstText( required any node, required string xpath ) {
    var n = xmlSearch( node, xpath );
    return arrayLen( n ) ? trim( n[1].xmlText ?: "" ) : "";
  }

}
