function FindProxyForURL(url, host) {
    if(shExpMatch ( url, "*noproxy*")) return "DIRECT";
    return "PROXY localhost:13081";
}
