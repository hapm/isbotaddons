alias http {
    var %flags, %p = 1, %data, %cbalias, %binout, %file, %params, %resource, %server, %port
    %params = $1-
    if ($left($1, 1) == -) {
        %flags = $mid($1, 2)
        %params = $2-
    }
    var %method = GET
    if (p isin %flags) %method = POST
    var %url = $gettok(%params, 1, 32) | %params = $gettok(%params, 2-, 32)
    if (!$regex(\http://([-A-Z0-9.]+(?::[0-9]+)?)(/[-A-Z0-9+&@#/%=~_|!:,.;]*)?(\?[-A-Z0-9+&@#/%=~_|!:,.;]*)?\i, %url)) return
    %server = $regml(1)
    %resource = $regml(2) $+ $regml(3)
    if ($regex(\http://([-A-Z0-9.]+)(?::([0-9]+))\i, %server)) { 
        %server = $regml(1)
        %port = $regml(2)
    }
    fopen -no tmp request.tmp
    fwrite -n tmp %method %resource HTTP/1.1
    fwrite -n tmp Host: %server
    fwrite -n tmp Connection: close
    if (a isin %flags) %cbalias = $gettok(%params, 1, 32) | %params = $gettok(%params, 2-, 32)
    if (b isin %flags) %binout = $gettok(%params, 1, 32) | %params = $gettok(%params, 2-, 32)
    if (f isin %flags) {
        if ($left(%params, 1) == ") {
            %file = $mid(%params, 2, $calc($pos(%params, 2)-2))
            %params = $mid(%params, $calc($pos(%params, 2)+1))
        }
        else {
            %file = $gettok(%params, 1, 32) | %params = $gettok(%params, 2-, 32)
        }
    }
    if (%method == POST) {
        if (v isin %flags) %data = $3
        else %data = - $+ $3-
    }
}

on 1:SOCKOPEN:http.post: {
}

on 1:SOCKOPEN:http.get: {
}

on 1:SOCKREAD:http.*: {
}