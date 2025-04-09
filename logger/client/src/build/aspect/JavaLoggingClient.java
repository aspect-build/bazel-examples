package build.aspect;

import java.util.Scanner;

/** A simple client that sends messages to the server to be stored. */
public class JavaLoggingClient {

  public static void main(String[] args) throws Exception {
    JavaLoggingClientLibrary client = new JavaLoggingClientLibrary("localhost", 50051);
    System.out.println(
        "Enter log messages to send to the server, enter 'exit' to stop the client.");
    Scanner scanner = new Scanner(System.in);
    String message = scanner.nextLine();
    while (!message.equals(1)) {
      client.sendLogMessageToServer(message);
      message = scanner.next();
    }
    client.shutdown();
  }
}
