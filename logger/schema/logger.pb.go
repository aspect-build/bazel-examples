// Code generated by protoc-gen-go. DO NOT EDIT.
// versions:
// 	protoc-gen-go v1.31.0
// 	protoc        v5.27.1
// source: logger/schema/logger.proto

package logger

import (
	context "context"
	grpc "google.golang.org/grpc"
	codes "google.golang.org/grpc/codes"
	status "google.golang.org/grpc/status"
	protoreflect "google.golang.org/protobuf/reflect/protoreflect"
	protoimpl "google.golang.org/protobuf/runtime/protoimpl"
	reflect "reflect"
	sync "sync"
)

const (
	// Verify that this generated code is sufficiently up-to-date.
	_ = protoimpl.EnforceVersion(20 - protoimpl.MinVersion)
	// Verify that runtime/protoimpl is sufficiently up-to-date.
	_ = protoimpl.EnforceVersion(protoimpl.MaxVersion - 20)
)

type LogMessage struct {
	state         protoimpl.MessageState
	sizeCache     protoimpl.SizeCache
	unknownFields protoimpl.UnknownFields

	Message string `protobuf:"bytes,1,opt,name=message,proto3" json:"message,omitempty"`
	Time    int64  `protobuf:"varint,2,opt,name=time,proto3" json:"time,omitempty"`
}

func (x *LogMessage) Reset() {
	*x = LogMessage{}
	if protoimpl.UnsafeEnabled {
		mi := &file_logger_schema_logger_proto_msgTypes[0]
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		ms.StoreMessageInfo(mi)
	}
}

func (x *LogMessage) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*LogMessage) ProtoMessage() {}

func (x *LogMessage) ProtoReflect() protoreflect.Message {
	mi := &file_logger_schema_logger_proto_msgTypes[0]
	if protoimpl.UnsafeEnabled && x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use LogMessage.ProtoReflect.Descriptor instead.
func (*LogMessage) Descriptor() ([]byte, []int) {
	return file_logger_schema_logger_proto_rawDescGZIP(), []int{0}
}

func (x *LogMessage) GetMessage() string {
	if x != nil {
		return x.Message
	}
	return ""
}

func (x *LogMessage) GetTime() int64 {
	if x != nil {
		return x.Time
	}
	return 0
}

type Empty struct {
	state         protoimpl.MessageState
	sizeCache     protoimpl.SizeCache
	unknownFields protoimpl.UnknownFields
}

func (x *Empty) Reset() {
	*x = Empty{}
	if protoimpl.UnsafeEnabled {
		mi := &file_logger_schema_logger_proto_msgTypes[1]
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		ms.StoreMessageInfo(mi)
	}
}

func (x *Empty) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*Empty) ProtoMessage() {}

func (x *Empty) ProtoReflect() protoreflect.Message {
	mi := &file_logger_schema_logger_proto_msgTypes[1]
	if protoimpl.UnsafeEnabled && x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use Empty.ProtoReflect.Descriptor instead.
func (*Empty) Descriptor() ([]byte, []int) {
	return file_logger_schema_logger_proto_rawDescGZIP(), []int{1}
}

var File_logger_schema_logger_proto protoreflect.FileDescriptor

var file_logger_schema_logger_proto_rawDesc = []byte{
	0x0a, 0x1a, 0x6c, 0x6f, 0x67, 0x67, 0x65, 0x72, 0x2f, 0x73, 0x63, 0x68, 0x65, 0x6d, 0x61, 0x2f,
	0x6c, 0x6f, 0x67, 0x67, 0x65, 0x72, 0x2e, 0x70, 0x72, 0x6f, 0x74, 0x6f, 0x22, 0x3a, 0x0a, 0x0a,
	0x4c, 0x6f, 0x67, 0x4d, 0x65, 0x73, 0x73, 0x61, 0x67, 0x65, 0x12, 0x18, 0x0a, 0x07, 0x6d, 0x65,
	0x73, 0x73, 0x61, 0x67, 0x65, 0x18, 0x01, 0x20, 0x01, 0x28, 0x09, 0x52, 0x07, 0x6d, 0x65, 0x73,
	0x73, 0x61, 0x67, 0x65, 0x12, 0x12, 0x0a, 0x04, 0x74, 0x69, 0x6d, 0x65, 0x18, 0x02, 0x20, 0x01,
	0x28, 0x03, 0x52, 0x04, 0x74, 0x69, 0x6d, 0x65, 0x22, 0x07, 0x0a, 0x05, 0x45, 0x6d, 0x70, 0x74,
	0x79, 0x32, 0x31, 0x0a, 0x06, 0x4c, 0x6f, 0x67, 0x67, 0x65, 0x72, 0x12, 0x27, 0x0a, 0x0e, 0x53,
	0x65, 0x6e, 0x64, 0x4c, 0x6f, 0x67, 0x4d, 0x65, 0x73, 0x73, 0x61, 0x67, 0x65, 0x12, 0x0b, 0x2e,
	0x4c, 0x6f, 0x67, 0x4d, 0x65, 0x73, 0x73, 0x61, 0x67, 0x65, 0x1a, 0x06, 0x2e, 0x45, 0x6d, 0x70,
	0x74, 0x79, 0x22, 0x00, 0x42, 0x56, 0x0a, 0x15, 0x62, 0x75, 0x69, 0x6c, 0x64, 0x2e, 0x61, 0x73,
	0x70, 0x65, 0x63, 0x74, 0x2e, 0x65, 0x78, 0x61, 0x6d, 0x70, 0x6c, 0x65, 0x73, 0x42, 0x0c, 0x47,
	0x72, 0x65, 0x65, 0x74, 0x65, 0x72, 0x50, 0x72, 0x6f, 0x74, 0x6f, 0x50, 0x01, 0x5a, 0x2d, 0x67,
	0x69, 0x74, 0x68, 0x75, 0x62, 0x2e, 0x63, 0x6f, 0x6d, 0x2f, 0x61, 0x73, 0x70, 0x65, 0x63, 0x74,
	0x2d, 0x62, 0x75, 0x69, 0x6c, 0x64, 0x2f, 0x62, 0x61, 0x7a, 0x65, 0x6c, 0x2d, 0x65, 0x78, 0x61,
	0x6d, 0x70, 0x6c, 0x65, 0x73, 0x2f, 0x6c, 0x6f, 0x67, 0x67, 0x65, 0x72, 0x62, 0x06, 0x70, 0x72,
	0x6f, 0x74, 0x6f, 0x33,
}

var (
	file_logger_schema_logger_proto_rawDescOnce sync.Once
	file_logger_schema_logger_proto_rawDescData = file_logger_schema_logger_proto_rawDesc
)

func file_logger_schema_logger_proto_rawDescGZIP() []byte {
	file_logger_schema_logger_proto_rawDescOnce.Do(func() {
		file_logger_schema_logger_proto_rawDescData = protoimpl.X.CompressGZIP(file_logger_schema_logger_proto_rawDescData)
	})
	return file_logger_schema_logger_proto_rawDescData
}

var file_logger_schema_logger_proto_msgTypes = make([]protoimpl.MessageInfo, 2)
var file_logger_schema_logger_proto_goTypes = []interface{}{
	(*LogMessage)(nil), // 0: LogMessage
	(*Empty)(nil),      // 1: Empty
}
var file_logger_schema_logger_proto_depIdxs = []int32{
	0, // 0: Logger.SendLogMessage:input_type -> LogMessage
	1, // 1: Logger.SendLogMessage:output_type -> Empty
	1, // [1:2] is the sub-list for method output_type
	0, // [0:1] is the sub-list for method input_type
	0, // [0:0] is the sub-list for extension type_name
	0, // [0:0] is the sub-list for extension extendee
	0, // [0:0] is the sub-list for field type_name
}

func init() { file_logger_schema_logger_proto_init() }
func file_logger_schema_logger_proto_init() {
	if File_logger_schema_logger_proto != nil {
		return
	}
	if !protoimpl.UnsafeEnabled {
		file_logger_schema_logger_proto_msgTypes[0].Exporter = func(v interface{}, i int) interface{} {
			switch v := v.(*LogMessage); i {
			case 0:
				return &v.state
			case 1:
				return &v.sizeCache
			case 2:
				return &v.unknownFields
			default:
				return nil
			}
		}
		file_logger_schema_logger_proto_msgTypes[1].Exporter = func(v interface{}, i int) interface{} {
			switch v := v.(*Empty); i {
			case 0:
				return &v.state
			case 1:
				return &v.sizeCache
			case 2:
				return &v.unknownFields
			default:
				return nil
			}
		}
	}
	type x struct{}
	out := protoimpl.TypeBuilder{
		File: protoimpl.DescBuilder{
			GoPackagePath: reflect.TypeOf(x{}).PkgPath(),
			RawDescriptor: file_logger_schema_logger_proto_rawDesc,
			NumEnums:      0,
			NumMessages:   2,
			NumExtensions: 0,
			NumServices:   1,
		},
		GoTypes:           file_logger_schema_logger_proto_goTypes,
		DependencyIndexes: file_logger_schema_logger_proto_depIdxs,
		MessageInfos:      file_logger_schema_logger_proto_msgTypes,
	}.Build()
	File_logger_schema_logger_proto = out.File
	file_logger_schema_logger_proto_rawDesc = nil
	file_logger_schema_logger_proto_goTypes = nil
	file_logger_schema_logger_proto_depIdxs = nil
}

// Reference imports to suppress errors if they are not otherwise used.
var _ context.Context
var _ grpc.ClientConnInterface

// This is a compile-time assertion to ensure that this generated file
// is compatible with the grpc package it is being compiled against.
const _ = grpc.SupportPackageIsVersion6

// LoggerClient is the client API for Logger service.
//
// For semantics around ctx use and closing/ending streaming RPCs, please refer to https://godoc.org/google.golang.org/grpc#ClientConn.NewStream.
type LoggerClient interface {
	SendLogMessage(ctx context.Context, in *LogMessage, opts ...grpc.CallOption) (*Empty, error)
}

type loggerClient struct {
	cc grpc.ClientConnInterface
}

func NewLoggerClient(cc grpc.ClientConnInterface) LoggerClient {
	return &loggerClient{cc}
}

func (c *loggerClient) SendLogMessage(ctx context.Context, in *LogMessage, opts ...grpc.CallOption) (*Empty, error) {
	out := new(Empty)
	err := c.cc.Invoke(ctx, "/Logger/SendLogMessage", in, out, opts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

// LoggerServer is the server API for Logger service.
type LoggerServer interface {
	SendLogMessage(context.Context, *LogMessage) (*Empty, error)
}

// UnimplementedLoggerServer can be embedded to have forward compatible implementations.
type UnimplementedLoggerServer struct {
}

func (*UnimplementedLoggerServer) SendLogMessage(context.Context, *LogMessage) (*Empty, error) {
	return nil, status.Errorf(codes.Unimplemented, "method SendLogMessage not implemented")
}

func RegisterLoggerServer(s *grpc.Server, srv LoggerServer) {
	s.RegisterService(&_Logger_serviceDesc, srv)
}

func _Logger_SendLogMessage_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(LogMessage)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(LoggerServer).SendLogMessage(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: "/Logger/SendLogMessage",
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(LoggerServer).SendLogMessage(ctx, req.(*LogMessage))
	}
	return interceptor(ctx, in, info, handler)
}

var _Logger_serviceDesc = grpc.ServiceDesc{
	ServiceName: "Logger",
	HandlerType: (*LoggerServer)(nil),
	Methods: []grpc.MethodDesc{
		{
			MethodName: "SendLogMessage",
			Handler:    _Logger_SendLogMessage_Handler,
		},
	},
	Streams:  []grpc.StreamDesc{},
	Metadata: "logger/schema/logger.proto",
}
