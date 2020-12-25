## A set of general purpose `iptables` rules for Android & Unix based OS

I had been using these rules for 6 months or so on both my rooted Android kernel 3.10 Android 5.1.1 and on my Linux machine, thought it would be a good idea to share these with the world. It's relatively a good idea to have `iptables` rules on a rooted device, or any Unix based OS.

### Rules included on the **simplified.sh** script

The `simplified.sh` rules are pretty straightforward. Basically drop everything but accept anything on port 443(https) and 80(http) for general web browsing. Also dropping all connections for ipv6 addresses. For Android devices running kernel > 4.x you can replace `-m state --state` with `-m conntrack --ctstate` because conntrack does a more granular level packet filtering compared to `-m state --state` rule, and the phone I have, which I ended up using as a router, has kernel version of 3.10, hence conntrack wasn't baked into iptables binary at that time. Now, with `simplified.sh` on Android devices, you'll be able to surf the internet, without any issues(hopefully, if you do, make sure to open an issue) while using mobile data and wifi. The same goes for Linux, just normal web browsing.

## Rules included on the `simple_plus.sh` script
 
The `simple_plus` rules are basically `simplified.sh` but with some extra stuffs. Some of the rules were adopted from custom scripts on afwall(https://github.com/ukanth/afwall)+ github wiki page. For instance, 

1. The `iptables -I INPUT -p 41 -j DROP` means drop everything that masks as ipv4 in the form of ipv6.

2. `iptables -I INPUT -p tcp --match recent --update --seconds 60 --name TCP-PORTSCAN -j DROP` drops portscans 

3. `iptables -A INPUT -m string --algo bm --hex-string '|28 29 20 7B|' -j DROP` disables shell shock

More stuff on the afwall+ wiki.

## Rules included on the `extreme_rules.sh`

For this I had to do a bit of googling and had to include a bunch of extra rules which I think is a bit of overkill, but meh, better to include these rules, it's harmless anyways since default policy is already set to drop. Stuffs like dropping invalid packets, blocking icmp ping requests and adding multiport rules for blocking a few extra ports and also dropping all packets going out of ports ranging from 8001 to port 65535 defining with this rule `iptables -I OUTPUT -p tcp --dport 8001:65535`. I've had a couple of issues on my Linux box with the 8001:65535 because it blocked irc, however, replacing OUTPUT with INPUT seemed to have solved the problem for me for some weird reason. On Android it works without any issues.

**I've had no issues with dnscrypt-proxy to work with these rules, make sure to include `iptables -I OUTPUT -p udp --sport 443 -j ACCEPT` in your set of rules. I used dnsfilter to route everything through dnscrypt. Always have loopback accepted when using dnscrypt**

***If you're planning to use these rules for usb-tether/access-point/hotspot, make sure to make the default policies for INPUT, OUTPUT and FORWARD as accept like so,***
```sh
iptables -P INPUT -j ACCEPT
iptables -P OUTPUT -j ACCEPT
iptables -P FORWARD -j ACCEPT
```

Also, if your Android OS supports init scripts or if you're using magisk as root manager, you can use `init-rules.sh` script to start the script at boot time. I've included sleep 10, which is the time my phone takes to proprerly startup. The reason I included a sleep interval is because the rules get overwritten by the time the phone is completely on, at least that happens for me(probably SELinux stuff), If you happen to use magisk, you can put this script with `chmod 0700` and place it under `/data/adb/service.d/`.

The script sleeps for 10 seconds for the phone to properly boot up, then mounts /system partition as read-only, then applies all the rules.

I've been searching for a while on iptables for Android, and just came up with this. Hopefully this comes in handy (:

**Also**

I came up with this script to block apps with iptables based on their uids.
You could use `pm dump 'package name' | grep userId` to get the userId of the apps. For example, to get the userId of Chrome browser you'd have to type,

`pm dump com.android.chrome | grep userId` and this should give you the userId of chrome. Now, to actually block chrome from accessing the internet, you'd type in, 

```sh
iptables -I INPUT -m owner --uid-owner 'chrome uid' -j DROP
iptables -I OUTPUT -m owner --uid-owner 'chrome uid' -j DROP
iptables -I FORWARD -m owner --uid-owner 'chrome uid' -j DROP
```
Where `chrome uid` is the uid number of your chrome browser.

Now, if you're planning to use your phone for tether/hotspot, and want all apps to not access the internet, accept the device you're tethering to, you'd have to first gather uuid for all the apps on your phone, and block them. To do that, you could use a for loop to cat out all the uids to a text file, like so;

```sh
for i in $(pm list packages | sed 's/package://g'); do
	pm dump $i | grep userId | awk '{ print $1 }' | sed 's/userId=//g' | grep -v launch >> uids.txt
done
```

This should dump all the uid's to a txt file. Remember to have `awk` and `sed` binaries set to your executable path.

Now, to block all internet access to literally everything, you'd type in;
```
for i in $(cat path/to/uids.txt); do
	iptables -I INPUT -m owner --uid-owner $i -j DROP
	iptables -I OUTPUT -m owner --uid-owner $i -j DROP
	iptables -I FORWARD -m owner --uid-owner $i -j DROP
done
```

And to block internet access to root uid, just do;

```sh
for i in $(cat path/to/uids.txt); do
	iptables -I INPUT -m owner --uid-owner 0 -j DROP
	iptables -I OUTPUT -m owner --uid-owner 0 -j DROP
	iptables -I FORWARD -m owner --uid-owner 0 -j DROP
done
```

However, I'm pretty sure uid.txt would have userId 0 already included. 

This should probably do the job fine.

### For open-source apps recommendations and more check out this(https://github.com/samiuljoy/android-recommendations) repository.

### Feel free to open issues

Feel free to support at [bitcoin] 13erq7DDXDuqqBohht3UNyuJCXtpJcWGSe
