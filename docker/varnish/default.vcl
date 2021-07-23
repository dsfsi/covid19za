vcl 4.0;

backend default {
    .host = "127.0.0.1";
    .port = "8081";
}

sub vcl_recv {
    # Headers that prevent Varnish from caching, and are not used.
    unset req.http.Authorization;
    unset req.http.Cookie;
}
