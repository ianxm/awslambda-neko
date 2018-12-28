package awslambda.runtime;

import neko.Lib;
import neko.vm.Loader;
import neko.vm.Module;
import haxe.Http;

/**
 * Implements the aws lambda runtime api for neko.
 */
class NekoRuntime {
    private static var LOG_TAG(default,null) = "LAMBDA_RUNTIME";
    private static var REQUEST_ID_HEADER(default,null) = "Lambda-Runtime-Aws-Request-Id";
    private static var TRACE_ID_HEADER(default,null) = "Lambda-Runtime-Trace-Id";
    private static var CLIENT_CONTEXT_HEADER(default,null) = "Lambda-Runtime-Client-Context";
    private static var COGNITO_IDENTITY_HEADER(default,null) = "Lambda-Runtime-Cognito-Identity";
    private static var DEADLINE_MS_HEADER(default,null) = "Lambda-Runtime-Deadline-Ms";
    private static var FUNCTION_ARN_HEADER(default,null) = "Lambda-Runtime-Invoked-Function-Arn";

    private static var VERSION(default,null) = "0.0.1";
    private static var USER_AGENT(default,null) = "AWS_Lambda_Neko/" + VERSION;
    private static var CONTENT_TYPE(default,null) = "text/html";

    private static var HANDLER_NAME(default,null) = "_HANDLER";
    private static var ROOT_NAME(default,null) = "LAMBDA_TASK_ROOT";
    private static var RUNTIME_API_NAME(default,null) = "AWS_LAMBDA_RUNTIME_API";

    private static var handler(default,default) :String;
    private static var root(default,default) :String;
    private static var runtime(default,default) :String;

    private var requestId(default,default) :String;
    private var loader(default,null) :Loader;
    private var module(default,null) :Module;

    /**
     * Start the lambda container. This is called by bootstrap.
     */
    public static function main() {
        handler = Sys.getEnv(HANDLER_NAME);
        root = Sys.getEnv(ROOT_NAME);
        runtime = Sys.getEnv(RUNTIME_API_NAME);

        Lib.println('starting neko runtime v$VERSION');
        var runtime = new NekoRuntime();
        runtime.runHandler();
    }

    /**
     * Init the neko handler implementation module.
     */
    public function new() {
        Lib.println('loading lambda_function module');
        loader = Loader.local();
        module = loader.loadModule('lambda_function');
    }

    /**
     * The execution loop.
     */
    public function runHandler() {
        // loop forever
        while (true) {
            try {
                getNext();
            } catch (e :Dynamic) {
                Lib.println('error: $e');
                Sys.sleep(1); // wait a sec
            }
        }
        Lib.println("neko runtime exiting");
    }

    /**
     * Get an event and process it.
     */
    private function getNext() {
        var nextUrl = '$runtime/2018-06-01/runtime/invocation/next';
        var request = new Http(nextUrl);
        request.setHeader("User-Agent", USER_AGENT);
        request.onData = function(data) {
            requestId = request.responseHeaders.get(REQUEST_ID_HEADER);
            Lib.println('request: $data');
            var result = tryCallHandler(data);
            postSuccess(result);
        }
        request.onError = function(msg) {
            postFailure(msg);
            throw msg;
        }
        request.request(false);
    }

    /**
     * Call the implementation module with an event.
     *
     * @param data the request data
     */
    private function tryCallHandler(data) {
        module.setExport('event', data);
        module.execute();
        var result = module.getExports().get('result');
        return result;
    }

    /**
     * Post a success message back to aws.
     */
    private function postSuccess(payload) {
        var url = '$runtime/2018-06-01/runtime/invocation/$requestId/response';
        doPost(url, payload);
    }

    /**
     * Post a failure message back to aws.
     */
    private function postFailure(payload) {
        var url = '$runtime/2018-06-01/runtime/invocation/$requestId/error';
        doPost(url, payload);
    }

    /**
     * Make the HTTP post request.
     *
     * @param url the url
     * @param payload the HTTP payload
     */
    private function doPost(url :String, payload :String) {
        Lib.println('response: $payload');
        var request = new Http(url);
        request.setHeader("User-Agent", USER_AGENT);
        request.setHeader("Content-Type", CONTENT_TYPE);
        request.setHeader("Content-Length", Std.string(payload.length));
        request.setPostData(payload);
        request.onData = function(data) {
            Lib.println('result data: $data');
        }
        request.onError = function(msg) {
            Lib.println('result error: $msg');
        }
        request.request(true);
    }
}
