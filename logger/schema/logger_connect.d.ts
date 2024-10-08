// @generated by protoc-gen-connect-es v1.0.0 with parameter "keep_empty_files=true,target=js+dts"
// @generated from file logger/schema/logger.proto (syntax proto3)
/* eslint-disable */
// @ts-nocheck

import { Empty, LogMessage } from "./logger_pb.js";
import { MethodKind } from "@bufbuild/protobuf";

/**
 * @generated from service Logger
 */
export declare const Logger: {
  readonly typeName: "Logger",
  readonly methods: {
    /**
     * @generated from rpc Logger.SendLogMessage
     */
    readonly sendLogMessage: {
      readonly name: "SendLogMessage",
      readonly I: typeof LogMessage,
      readonly O: typeof Empty,
      readonly kind: MethodKind.Unary,
    },
  }
};

