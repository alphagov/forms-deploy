# log_to_splunk

This module sets up a Kinesis Stream to send CloudWatch logs to splunk. The stream is accessible to CRIBL (the Cyber Engineering Team's tool), which routes the logs to Splunk.

This creates a central stream and authorises other accounts to subscribe to it.

We have used (and modified where necessary) [the code provided by the Cyber Engineering Team](https://github.com/CO-Cyber-Security/cribl-cloudwatch-kinesis).

After creating these resources, we need to give cyber the values of the following before creating any subscriptions:
- kinesis stream ARN
- assume role ARN and
- external ID
