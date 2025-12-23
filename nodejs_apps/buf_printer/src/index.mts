import { create } from "@bufbuild/protobuf";
import { ExampleUserSchema } from "../genproto/example/v1/example_pb.js";

const user = create(ExampleUserSchema, {
  id: "123e4567-e89b-12d3-a456-426614174000",
  email: "alice@example.com",
  displayName: "Alice",
  age: 42,
});

console.log(user);
