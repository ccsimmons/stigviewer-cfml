component {

  function render( required struct meta, required struct data ) {
    var h = arrayNew(1);

    arrayAppend( h, "<!doctype html>" );
    arrayAppend( h, "<html><head><meta charset=""utf-8"">" );

    var titleText = "STIG Report";
    if ( structKeyExists( meta, "title" ) && len( meta.title & "" ) ) {
      titleText = meta.title;
    }

    arrayAppend( h, "<title>" & _e( titleText ) & "</title>" );
    arrayAppend( h, "<style>" );
    arrayAppend( h, "body{font-family:system-ui,-apple-system,Segoe UI,Roboto,Helvetica,Arial,sans-serif; margin:24px;}" );
    arrayAppend( h, "h1{margin:0 0 4px 0;}" );
    arrayAppend( h, "h2{margin-top:24px;}" );
    arrayAppend( h, "table{border-collapse:collapse; width:100%;}" );
    arrayAppend( h, "th,td{border:1px solid ##ddd; padding:8px; vertical-align:top;}" );
    arrayAppend( h, "th{background:##f7f7f7; text-align:left;}" );
    arrayAppend( h, "</style></head><body>" );

    arrayAppend( h, "<h1>" & _e( titleText ) & "</h1>" );

    if ( structKeyExists( meta, "version" ) && len( meta.version & "" ) ) {
      arrayAppend( h, "<div><strong>Version:</strong> " & _e( meta.version ) & "</div>" );
    }

    var total = 0;
    if ( structKeyExists( data, "totalRuleCount" ) ) {
      total = data.totalRuleCount;
    } else if ( structKeyExists( data, "rules" ) && isArray( data.rules ) ) {
      total = arrayLen( data.rules );
    }
    arrayAppend( h, "<div><strong>Total rules:</strong> " & total & "</div>" );

    var matched = 0;
    if ( structKeyExists( meta, "matchedRecordCount" ) ) matched = meta.matchedRecordCount;
    else if ( structKeyExists( data, "rules" ) && isArray( data.rules ) ) matched = arrayLen( data.rules );
    arrayAppend( h, "<div><strong>Matched Record Count:</strong> " & matched & "</div>" );

    var sf = "none";
    if ( structKeyExists( meta, "severityFilter" ) && len( meta.severityFilter & "" ) ) sf = meta.severityFilter;
    arrayAppend( h, "<div><strong>Severity Filter:</strong> " & _e( sf ) & "</div>" );

    arrayAppend( h, "<h2>Rules</h2>" );
    arrayAppend( h, "<table><thead><tr><th>ID</th><th>Req ID</th><th>Severity</th><th>Title</th><th>Check</th><th>Fix</th></tr></thead><tbody>" );

    var rules = [];
    if ( structKeyExists( data, "rules" ) && isArray( data.rules ) ) rules = data.rules;

    for ( var r in rules ) {
      var sev = "unknown";
      if ( structKeyExists( r, "severity" ) && len( r.severity & "" ) ) sev = lcase( r.severity );

      arrayAppend( h,
        "<tr>" &
          "<td>" & _e( ( structKeyExists( r, "id" ) ? r.id : "" ) ) & "</td>" &
          "<td>" & _e( ( structKeyExists( r, "reqId" ) ? r.reqId : "" ) ) & "</td>" &
          "<td><strong>" & _e( ucase( sev ) ) & "</strong></td>" &
          "<td>" & _e( ( structKeyExists( r, "title" ) ? r.title : "" ) ) & "</td>" &
          "<td><pre style=""white-space:pre-wrap; margin:0;"">" & _e( ( structKeyExists( r, "check" ) ? r.check : "" ) ) & "</pre></td>" &
          "<td><pre style=""white-space:pre-wrap; margin:0;"">" & _e( ( structKeyExists( r, "fix" ) ? r.fix : "" ) ) & "</pre></td>" &
        "</tr>"
      );
    }

    arrayAppend( h, "</tbody></table>" );
    var genDate = structKeyExists( meta, "generatedOnDate" ) ? meta.generatedOnDate : dateFormat( now(), "mm/dd/yyyy" );
    var genTime = structKeyExists( meta, "generatedOnTime" ) ? meta.generatedOnTime : timeFormat( now(), "hh:mm:ss tt" );
    var svVer  = structKeyExists( meta, "stigViewerVersion" ) ? meta.stigViewerVersion : "unknown";

    arrayAppend( h, "<hr style=""margin:24px 0;"">" );
    arrayAppend( h, "<div style=""font-size:0.9em; color:##666;"">Generated on " & _e( genDate ) & " at " & _e( genTime ) & " by StigViewer CFML version " & _e( svVer ) & ".</div>" );

    arrayAppend( h, "</body></html>" );

    return arrayToList( h, chr(10) );
  }

  private string function _e( any s ) {
    return htmlEditFormat( s & "" );
  }

}
