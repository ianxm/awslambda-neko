package example;

import Type; // for ValueType
import awslambda.base.LambdaFunction;

/**
 * This is an example lambda handler. Lambda handlers must extend LambdaFunction and must override
 * lambdaHandler(event).
 *
 * example event: {"a": 1, "b": 2}
 */
class ExampleLambdaFunction extends LambdaFunction {
    /**
     * This is required.
     */
    public function new() {
        super();
    }

    /**
     * This is the actual lambda handler implementation. This is where you do what you want.
     *
     * @param event request as an anonymous object
     * @returns response as an anonymous object
     * @throws string on error
     */
    private override function lambdaHandler( event ){
        // validate input
        if( !validate(event.a) || !validate(event.b) ){
            throw 'validation failure: event must provide "a" and "b", and they must be numbers';
        }

        // do stuff
        var sum = event.a + event.b;

        // return response as an anonymous object
        return {sum: sum};
    }

    /**
     * @return true if param is valid
     */
    private function validate( param ){
        return param != null && (Type.typeof(param) == ValueType.TInt || Type.typeof(param) == ValueType.TFloat);
    }

    /**
     * The main function instantiates this class and calls "run." This is required.
     */
    public static function main() {
        new ExampleLambdaFunction().run();
    }
}
