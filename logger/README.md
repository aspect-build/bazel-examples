# Logger application

This example contains a logging service, with code in lots of languages, communicating with gRPC. It's meant as a simulation of the kind of monorepo you likely work in.

Here are the components of the application:

- schema/ generates code for all languages to agree on the protocol, using protobuf and gRPC.
- backend/ has a server written in Go which stores messages.
- client/ is a sample of a program that wants to store log messages, written in Java.
- frontend/ is a web site written in TypeScript.
- cli/ is a terminal-based frontend for viewing the messages, written in Python.
- ios/ contains an iOS application that sends log messages to the backend server, written in Swift.

It was originally in the https://github.com/aspect-build/codelabs repo.
We stopped maintaining that because it's confusing for novice product engineers to drop into an "all languages at once"
monorepo, and have an easier time starting from `aspect init`.
