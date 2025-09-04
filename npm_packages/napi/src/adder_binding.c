#define NAPI_VERSION 3
#include <node_api.h>
#include "adder.h"

static napi_value Add(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2];
    napi_value this_arg;
    void* data = NULL;
    
    napi_status status = napi_get_cb_info(env, info, &argc, args, &this_arg, &data);
    if (status != napi_ok) {
        napi_throw_error(env, NULL, "Failed to parse arguments");
        return NULL;
    }
    
    if (argc < 2) {
        napi_throw_type_error(env, NULL, "Wrong number of arguments");
        return NULL;
    }
    
    int32_t first = 0, second = 0;
    status = napi_get_value_int32(env, args[0], &first);
    if (status != napi_ok) {
        napi_throw_type_error(env, NULL, "First argument must be a number");
        return NULL;
    }
    
    status = napi_get_value_int32(env, args[1], &second);
    if (status != napi_ok) {
        napi_throw_type_error(env, NULL, "Second argument must be a number");
        return NULL;
    }
    
    int result = add(first, second);
    
    napi_value return_val;
    status = napi_create_int32(env, result, &return_val);
    if (status != napi_ok) {
        napi_throw_error(env, NULL, "Unable to create return value");
        return NULL;
    }
    
    return return_val;
}

static napi_value Init(napi_env env, napi_value exports) {
    napi_value fn;
    napi_status status = napi_create_function(env, NULL, 0, Add, NULL, &fn);
    if (status != napi_ok) {
        napi_throw_error(env, NULL, "Unable to wrap native function");
        return NULL;
    }
    
    status = napi_set_named_property(env, exports, "add", fn);
    if (status != napi_ok) {
        napi_throw_error(env, NULL, "Unable to populate exports");
        return NULL;
    }
    
    return exports;
}

NAPI_MODULE_INIT() {
    return Init(env, exports);
}
