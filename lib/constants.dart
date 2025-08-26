var workflowResponses=
['{"sessionId":"12345","statusCode":200}',
 '{"sessionId":"67890","statusCode":200}',
 '{"sessionId":"54321","statusCode":200}'];
String workflowResponse() {
  return workflowResponses.removeLast();
}