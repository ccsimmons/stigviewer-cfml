
component {

  function transform( required string xmlString, required string xslString ) {
    var StringReader = createObject( "java", "java.io.StringReader" );
    var StringWriter = createObject( "java", "java.io.StringWriter" );

    var StreamSource = createObject( "java", "javax.xml.transform.stream.StreamSource" );
    var StreamResult = createObject( "java", "javax.xml.transform.stream.StreamResult" );
    var TransformerFactory = createObject( "java", "javax.xml.transform.TransformerFactory" );

    var xmlSource = StreamSource.init( StringReader.init( xmlString ) );
    var xslSource = StreamSource.init( StringReader.init( xslString ) );

    var tf = TransformerFactory.newInstance();
    var transformer = tf.newTransformer( xslSource );

    var out = StringWriter.init();
    transformer.transform( xmlSource, StreamResult.init( out ) );

    return out.toString();
  }

}
