# Some (hopefully) useful bash scripts

## DNSenum.sh ... DNS enumeration script

This scipt will print all **TXT**,**MX** and **NS** records for a given domain.  
It will attempt **Zone transfer** againts the Nameservers for the given domain.

If Zone transfer is not successful then DNS enumberation is executed.

## Usage

```bash
Syntax: dnsenum.sh [-d|h|f|a|t]
options:
-d     Domain to query.
-h     Print this Help.
-f     File for DNS enumeration
-s     DNS server used for quyering, defaults to resolv.conf
-t     Max background jobs to run.
```
Run enumeration against example.com domain and query subdomains in subdomain.txt  
10 backround jobs will be created.
```bash
dnsenum.sh -d example.com -f subdomain.txt -t 10
```
Run enumeration against example.com domain and query subdomains in subdomain.txt  
The DNS server 8.8.8.8 will be used for the DNS queries  
10 backround jobs will be created.
```bash
dnsenum.sh -d example.com -s 8.8.8.8 -f subdomain.txt -t 10
```
