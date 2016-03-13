This post is heavily inspired by Ruben Fonesca's work on writing AWS Lambda Functions in Go.  Please see his post here:
<http://blog.0x82.com/2014/11/24/aws-lambda-functions-in-go/>

AWS Lambda is a 'compute service that runs your code in response to events and automatically manages the new compute resources for you, making it easy to build applications that respond quickly to new information'.

There are many uses for such, and in my own work I am more interested in the ability to use them to process bursts of data relating to news and financial markets than the typical web applications.  So this post is written more with those concerns in mind.

Current supported runtimes (at least when I wrote the code, some months back) were Javascript (node.js) and Java, but I wanted to be able to write scripts in D, since that's what I use for my existing work.

First compile your D script on a linux machine:

`

module doit;
import std.stdio;

void main(string[] args)
{
	writefln("Hello world!");
	foreach(arg;args)
		writefln("you gave me: %s",arg);
	writefln("==");
	writefln("bye");
}

`

`dmd doit.d`

Then we need to create a javascript (node.js) module to fork to the binary.

`

'use strict';

var child_process = require('child_process');

// Set the PATH and LD_LIBRARY_PATH environment variables.
process.env['PATH'] = process.env['PATH'] + ':' + process.env['LAMBDA_TASK_ROOT'] + '/';
process.env['LD_LIBRARY_PATH'] = process.env['LAMBDA_TASK_ROOT'] + '/';

exports.handler = function(event, context) {
  var proc = child_process.exec('./doit ' + JSON.stringify(event) ,function(code,stdout,stderr) {
    console.log(stdout);
    context.succeed(stdout);
  });
}

`

Since dmd links phobos dynamically on linux, and phobos/druntime aren't installed on the AWS lambda server, we will need to upload these to the servers and tell the application where to find them.  (I should really have appended to LD_LIBRARY_PATH as I did with PATH).

Now one can follow the regular instructions for AWS Lambda: create a .zip file with the D binary, the JS file, and the following libraries (update version numbers as appropriate):

`

libcrypto.so.1.0.0
libphobos2.so.0.67
libevent-2.0.so.5
libssl.so.1.0.0

`

To create the lambda, use the aws command line tool as follows, changing region, function-name, zip-file name, role and handler as appropriate:

`
aws lambda create-function \
--region us-west-2 \
--function-name lambda \
--zip-file fileb://./lambda.zip \
--role arn:aws:iam::iam_number_here:role/lambda_basic_execution \
--handler lambda.handler \
--runtime nodejs

`

To invoke the lambda:
`

aws lambda invoke \
--invocation-type RequestResponse \
--function-name lambda \
--region us-west-2 \
--log-type Tail \
--payload '{"key1":"value1", "key2":"value2", "key3":"value3"}' \
outputfile.txt

`

And to list lambda functions on server:
`

aws lambda list-functions \
--max-items 10

`
