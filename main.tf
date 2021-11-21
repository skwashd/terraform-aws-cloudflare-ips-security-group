/**
 * Module populates an AWS security group ingress rules with Cloudflare source IPs. By default module only allows access for 443/tcp (https), but additional ports can be added.
 *
 * The Cloudflare provider requires an API. The IP lookup doesn't use the token to featch the values. Using `export CLOUDFLARE_API_TOKEN="YQSn-xWAQiiEh9qM58wZNnyQS7FUdoqGIUAbrh7T"` works. This nvalid token that passes validation [lifted from Cloudflare docs](https://developers.cloudflare.com/api/).
 */
