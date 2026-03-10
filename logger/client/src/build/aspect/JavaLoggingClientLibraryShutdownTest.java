package build.aspect;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.JUnit4;

/** Tests for JavaLoggingClientLibrary shutdown behavior. */
@RunWith(JUnit4.class)
public final class JavaLoggingClientLibraryShutdownTest {

  private JavaLoggingClientLibrary client;

  @Before
  public void setUp() {
    client = new JavaLoggingClientLibrary("localhost", 9999);
  }

  @After
  public void tearDown() throws InterruptedException {
    client.shutdown();
  }

  @Test
  public void testShutdownDoesNotThrow() throws InterruptedException {
    // shutdown() should complete without throwing even when the server is unreachable
    client.shutdown();
  }

  @Test
  public void testSendMessageToUnreachableServerDoesNotThrow() {
    // sendLogMessageToServer catches StatusRuntimeException internally
    client.sendLogMessageToServer("test message");
  }
}
