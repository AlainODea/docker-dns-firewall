docker-dns-firewall
===================
A recursive name server proxy/firewall using BIND9 with response policy zones (RPZ).

Forwards to existing name servers, as a recursive DNS firewall/proxy.

Usage
-----
Build Docker image with BIND9:

```shell
docker build . -t dns-firewall
```

Customize:
1. Customize **etc/bind/named.conf.options** setting **forwarders** to your network's name servers
2. Customize **etc/bind/db.allow-list.local** to contain your trusted domains

Run a Docker container with a BIND9 proxy/firewall configuration:

```shell
docker run -d --name dns-firewall -p 53:53 -p 53:53/udp -v (pwd)/etc/bind:/etc/bind dns-firewall
```

Testing
-------
Querying for an allowed domain (ex: example.com):

```shell
$ dig @localhost example.com

; <<>> DiG 9.10.6 <<>> @localhost example.com
; (2 servers found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 42802
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;example.com.                   IN      A

;; ANSWER SECTION:
example.com.            58310   IN      A       93.184.216.34

;; Query time: 2 msec
;; SERVER: 127.0.0.1#53(127.0.0.1)
;; WHEN: Sun May 05 19:09:12 NDT 2019
;; MSG SIZE  rcvd: 56

```

Querying for a deny-listed domain (ex: notgonnawork.example.com):

```shell
$ dig @localhost notgonnawork.example.com

; <<>> DiG 9.10.6 <<>> @localhost notgonnawork.example.com
; (2 servers found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NXDOMAIN, id: 44129
;; flags: qr rd ra; QUERY: 1, ANSWER: 0, AUTHORITY: 0, ADDITIONAL: 2

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;notgonnawork.example.com.      IN      A

;; ADDITIONAL SECTION:
deny-list.local.        1       IN      SOA     localhost. root.localhost. 1 3600 900 2592000 7200

;; Query time: 2 msec
;; SERVER: 127.0.0.1#53(127.0.0.1)
;; WHEN: Sun May 05 19:08:39 NDT 2019
;; MSG SIZE  rcvd: 118
```

References
----------
I referred to the following sites and documents to build this:
* https://topranks.github.io/2017/05/13/DNS-Whitelist-in-BIND-with-RPZ.html (does not work, but good explanations)
* https://www.isc.org/wp-content/uploads/2014/05/dns-firewall-howto.pdf (rough, lots of cruft, PDF, but it works)
* https://www.slideshare.net/MenandMice/bind-9-logging-best-practices
* https://ftp.isc.org/isc/bind9/cur/9.13/doc/arm/Bv9ARM.ch05.html (docs for RPZ directives)

Security Notes
--------------
* Hardened based on [CIS benchmark for BIND](https://www.cisecurity.org/benchmark/bind/) to
  harden this (if you see gaps, please open a PR or issue)
* Put a firewall around it. It has no built in client security and will allow any host to query
