# Pacproxy

Docker images of [Pacproxy](https://github.com/otahi/pacproxy/).
Pacproxy provides a proxy server controlled with your proxy.pac.

## Usage

You can use this container as a proxy server which can be controlled with proxy pac.
You can use Pacproxy server with `http_proxy` and `https_proxy` environment variables as same as usual proxy servers.

### For docker

Run your container with your proxy pac location.

```
docker run -d -p 3128:3128 -it otahi/pacproxy pacproxy -P http://example.com/proxy.pac
```
or

Put your pacproxy.yml with your own configuration on your currecnt directory.
```
docker run -d -p 3128:3128 -v`pwd`:/opt/pacproxy/work -it otahi/pacproxy
```

See  [pacproxy.yml](pacproxy.yml).

## Contributing

1. Fork it ( https://github.com/otahi/pacproxy/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
