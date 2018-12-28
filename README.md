## AWS Lambda Neko Runtime

AWS Lambda is a serverless architecture that can run microservices written in haxe and compiled to neko. This project contains the neko runtime as well as an example microservice implementation.

## Building and Installing

To build the runtime, run the build script included in this project. This will create two zip files in the dist directory.
1. `neko_runtime.zip` is the neko runtime
2. `lambda_function.zip` is the example implementation

To install the runtime
1. Create a lambda layer
2. Create a new version for the new lambda layer
3. Upload `neko_runtime.zip` and save
4. Create lambda function
5. Set the Runtime to 'custom'
5. Add the new layer you created to the new lambda function
6. upload `lambda_function.zip` and save

note: The 'Handler' configuration parameter from the lambda function code configuration panel is not used.

The example lambda function is set up and ready. Here are some test inputs:
1. {"a": 1, "b": 2} // returns sum=3
2. {"a": 1.1, "b": -2.3} // returns sum=-1.2
3. {"a": "car", "b": 2} // returns validation error
4. {"one": 1} // returns validation error

## Usage

To write your own lambda implementation, extend `awslambda.base.LambdaFunction` and fill in lambdaHandler(). The request event will be passed in as an anonymous object. lambdaHandler should return an anonymous object with the response, or throw a string containing an error message on failure.

Compile with `-lib awslambda-neko` to get the definition of `awslambda.base.LambdaFunction`.

The main function that creates your object and calls `run()` on the super class is required.

```
import awslambda.base.LambdaFunction;

class YourLambdaFunction extends LambdaFunction {
    public function new() {
        super();
    }

    private override function lambdaHandler( event ){
        // validate input

        // your implementation here

        // return response as an anonymous object
        return {};
    }

    public static function main() {
        new YourLambdaFunction().run();
    }
}
```
