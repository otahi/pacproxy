function FindProxyForURL(url, host) {
    return "PROXY localhost:3128; PROXY 7.8.9.10:8080";
    // return "DIRECT";
}
