// @generated by protoc-gen-es v1.3.0 with parameter "keep_empty_files=true,target=js+dts"
// @generated from file packages/schema/eliza.proto (package connectrpc.eliza.v1, syntax proto3)
/* eslint-disable */
// @ts-nocheck

import type {
  BinaryReadOptions,
  FieldList,
  JsonReadOptions,
  JsonValue,
  PartialMessage,
  PlainMessage,
} from '@bufbuild/protobuf';
import { Message, proto3 } from '@bufbuild/protobuf';

/**
 * @generated from message connectrpc.eliza.v1.SayRequest
 */
export declare class SayRequest extends Message<SayRequest> {
  /**
   * @generated from field: string sentence = 1;
   */
  sentence: string;

  constructor(data?: PartialMessage<SayRequest>);

  static readonly runtime: typeof proto3;
  static readonly typeName = 'connectrpc.eliza.v1.SayRequest';
  static readonly fields: FieldList;

  static fromBinary(
    bytes: Uint8Array,
    options?: Partial<BinaryReadOptions>
  ): SayRequest;

  static fromJson(
    jsonValue: JsonValue,
    options?: Partial<JsonReadOptions>
  ): SayRequest;

  static fromJsonString(
    jsonString: string,
    options?: Partial<JsonReadOptions>
  ): SayRequest;

  static equals(
    a: SayRequest | PlainMessage<SayRequest> | undefined,
    b: SayRequest | PlainMessage<SayRequest> | undefined
  ): boolean;
}

/**
 * @generated from message connectrpc.eliza.v1.SayResponse
 */
export declare class SayResponse extends Message<SayResponse> {
  /**
   * @generated from field: string sentence = 1;
   */
  sentence: string;

  constructor(data?: PartialMessage<SayResponse>);

  static readonly runtime: typeof proto3;
  static readonly typeName = 'connectrpc.eliza.v1.SayResponse';
  static readonly fields: FieldList;

  static fromBinary(
    bytes: Uint8Array,
    options?: Partial<BinaryReadOptions>
  ): SayResponse;

  static fromJson(
    jsonValue: JsonValue,
    options?: Partial<JsonReadOptions>
  ): SayResponse;

  static fromJsonString(
    jsonString: string,
    options?: Partial<JsonReadOptions>
  ): SayResponse;

  static equals(
    a: SayResponse | PlainMessage<SayResponse> | undefined,
    b: SayResponse | PlainMessage<SayResponse> | undefined
  ): boolean;
}
