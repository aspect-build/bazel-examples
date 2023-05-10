# Generate Java from WSDL
Java API for XML Web Services (JAX-WS) is a standardized API for creating and consuming SOAP (Simple Object Access Protocol) web services.

In this example, we'll create a SOAP web service and connect to it using JAX-WS using Bazel.

This is an answer to https://stackoverflow.com/questions/75836878/how-can-i-generate-java-code-from-wsdl-in-bazel

- Get a sample wsdl file
- Invoke https://mvnrepository.com/artifact/com.sun.xml.ws/jaxws-ri
- Reference: in maven, this is what calls it : https://github.com/mojohaus/jaxws-maven-plugin/blob/cc10c14811d5da4c719334e11c3482143acba592/src/main/java/org/codehaus/mojo/jaxws/AbstractJaxwsMojo.java#L392
- produces a jar on the classpath
- test that a java program can use it
