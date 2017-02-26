**PowerShell cloudbleed IE/Chrome check**


This script use [https://github.com/pirate/sites-using-cloudflare](https://github.com/pirate/sites-using-cloudflare) and check IE or Chrome history on the local machine for cloudbleed affected domain


To understand Cloudbleed you should read this [https://blog.cloudflare.com/incident-report-on-memory-leak-caused-by-cloudflare-parser-bug/](https://blog.cloudflare.com/incident-report-on-memory-leak-caused-by-cloudflare-parser-bug/)

In short, a bug in Cloudflare proxy leaked sensitive data between 2016-09 22 and 2017-02-18. This proxy service is used by many web sites and web services, from the small one to the Bigest.
Session data as been leaked, you should log out session from this website. 
In addition you should also try to reset password from this sites. 


this script is written in PowerShell, it is an alpha version. 
There is some change needed to improve performence

I use [System.IO.File]::OpenText instead of get-content (it take too long and using NET object require only few seconds)


**TODO**

* change parsing method for better perf 
* add Edge history
* Error Control