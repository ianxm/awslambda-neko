package awslambda.base;

import haxe.Json;
import neko.vm.Module;

/**
 * Super class for lambda handlers.
 */
class LambdaFunction {
    private function new() {
    }

    /**
     * Called by main. Loads the json request from the neko runtime, parses it, calls the subclass' handler, serializes
     * the response and passes it to the neko runtime.
     */
    public function run() {
        var module = Module.local();
        var event = module.getExports().get('event');
        if( event == null ){ // triggered when this module is loaded
            return;
        }
        var eventJson = Json.parse(event);

        var result :Dynamic;
        try {
            result = lambdaHandler(eventJson);
            result.status = 'success';
        } catch ( err :String ) {
            result = {status: "failure", message: err};
        }
        var resultJson = Json.stringify(result);
        module.setExport('result', resultJson);
    }

    /**
     * Derived classes must override this.
     */
    private function lambdaHandler( event ){
        throw "override this method";
        return null;
    }
}
