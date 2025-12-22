# proto-buf-go-ts

Minimal example showing **Protobuf + Buf (v2) + protovalidate** generating code for **Go** and **TypeScript**.

## Layout

- `protobuf/`: source `.proto` files
- `buf.yaml`: Buf module + deps + lint config
- `buf.gen.yaml`: code generation config
- `go/`: Go consumer + generated `genproto/`
- `typescript/`: TypeScript consumer + generated `genproto/`

## Prereqs

- Go
- Node.js + npm

This repo does not include Bazel for this example.

## Generate code

Install the Go plugin:

```bash
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
```

Install TS deps (includes `protoc-gen-es`):

```bash
cd typescript
npm install
cd ..
```

Install Buf (or run it via Go):

```bash
# If you have buf installed already:
buf --version

# Or run buf via go:
go run github.com/bufbuild/buf/cmd/buf@latest --version
```

Then generate:

```bash
# Using installed buf:
buf dep update
buf generate

# Or using go-run buf:
go run github.com/bufbuild/buf/cmd/buf@latest dep update
go run github.com/bufbuild/buf/cmd/buf@latest generate
```

## Compile-only consumers

Go:

```bash
cd go
go run ./cmd/example
```

TypeScript:

```bash
cd typescript
npm run build
node dist/index.js
```
