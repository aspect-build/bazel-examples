package build.aspect;

import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.JUnit4;

/** Hello world test. */
@RunWith(JUnit4.class)
public final class JavaLoggingClientLibraryTest {

  private JavaLoggingClientLibrary client;

  @Before
  public void setUp() throws Exception {
    client = new JavaLoggingClientLibrary("localhost", 8888);
  }

  @Test
  public void testHello() throws Exception {
    System.out.println("Hello Java!");
  }

  @Test
  public void testSendLogMessageToServer() throws Exception {
    client.sendLogMessageToServer("he3llo");
  }


}
