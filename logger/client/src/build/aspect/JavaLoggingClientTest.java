package build.aspect;

import static org.junit.Assert.assertEquals;

import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.JUnit4;

/** Hello world test. */
@RunWith(JUnit4.class)
public final class JavaLoggingClientTest {

  @Test
  public void testHello() throws Exception {
    System.out.println("Hello Java!");
  }

  @Test
  public void testHelloAgain() throws Exception {
    assertEquals(1, 1);
  }
}