# 💻 Suspend Sedation on Linux

**This post starts as a rant, but ends with some hope.. Bear with me 😀.**

I remember the good old days, in 2004 (or maybe 2005?).. My laptop was an iBook G4 running Debian GNU/Linux
and I could put that thing in suspend to RAM and it would last around a month.

Today, in 2025, the current situation around suspend to RAM on Linux is ridiculous.

I have two laptops I use regularly, a Lenovo Carbon X1 Gen 10 for personal use and a Dell Latitude 5490 for
work, both running a recent version of Ubuntu. And the both sucks in terms of power management, battery time
and suspend to RAM.

## The suspend to RAM dilemma

Let's start with the Lenovo. My Carbon X1 supports proper S3 suspend, which is basically the suspend to RAM level
where everything apart from the memory banks is powered off. This should allow for many days, if not weeks of suspend time.

The problem? After going to S3, the laptop never comes back. I had, as many other Lenovo Linux users, to select
s2idle in the BIOS, meaning the RAM doesn't go into the lower power mode and the NVME is kept powered on.

The result, is a couple of days of suspend time and if the battery runs off during suspend, most of the times my
LUKS partition gets corrupted and I have to recover it manually during the next boot. Fun, ha? 🤮

With the Dell, the problem is very similar. Dell decided to rip the S3 support from their BIOS and bend over to
mother Microsoft, so that Windows can wake the laptop up when it wants and do things you probably really don't want
it to do. Fun again, ha? 🤮

So, it's the same story as the Lenovo, if the battery runs out during, suspend, the LUKS partition will get corrupted,
yadda, yadda, yadda.

**I had to do something!**

## Suspend sedation to the rescue

The Debian wiki has a nice article about a technique called *suspend sedation*: https://wiki.debian.org/SystemdSuspendSedation.

The gist is that we can use a watchdog timer to wake up the laptop from s2idle and do something to mitigate this shit show.

If you are lucky and you can use hibernate, the Debian wiki covers how to hibernate your laptop from suspend after a certain time.

If you, like me, want (or are forced) to use secure boot, and cannot make your laptop go into hibernate, I crafted a poor man solution
for the issue.

I created a Systemd suspend sedation service that wakes up the laptop every two hours, check if the battery is less than a certain
threshold and, if it is, cleanly shuts down your laptop, preventing the nasty corruption I experienced many times.

**I know, it's sad, but man, when the world gives you lemon, you do something, right 🍋?**

```bash
❯❯❯ cat /etc/systemd/system/suspend-sedation.service
[Unit]
Description=Wake up periodically and check battery status

[Service]
Type=oneshot
RemainAfterExit=yes
Environment="ALARM_SEC=7200"
Environment="WAKEALARM=/sys/class/rtc/rtc0/wakealarm"
Environment="POWEROFF_LEVEL=10"

ExecStart=/usr/sbin/rtcwake --seconds $ALARM_SEC --auto --mode no
ExecStop=/bin/sh -c '\
  ALARM=$(cat $WAKEALARM); \
  NOW=$(date +%%s); \
  if [ -z "$ALARM" ] || [ "$NOW" -ge "$ALARM" ]; then \
    echo "suspend-sedation: Woke up without alarm set. Checking battery..."; \
    BATTERY_LEVEL=$(cat /sys/class/power_supply/BAT0/capacity); \
    if [ "$BATTERY_LEVEL" -lt "$POWEROFF_LEVEL" ]; then \
      echo "suspend-sedation: Battery level is $BATTERY_LEVEL% (< $POWEROFF_LEVEL%). Shutting down..."; \
      sleep 5; \
      /usr/bin/systemctl poweroff; \
      sync; \
    else \
      echo "suspend-sedation: Battery level is $BATTERY_LEVEL% (> $POWEROFF_LEVEL%). Suspending again..."; \
      sleep 5; \
      /usr/bin/systemctl suspend; \
    fi; \
  else \
    echo "suspend-sedation: Normal wake up before alarm. Nothing to do..."; \
    /usr/sbin/rtcwake --auto --mode disable; \
  fi \
'

[Install]
WantedBy=sleep.target
```

I hope this can help someone else 😁. You can change the environment variables to tune this, taking in account your preferences.

Since I'll probably end up tuning this service, here is the source where you'll be able to find the update version: [suspend-sedation.service](https://github.com/crisidev/dotfiles/blob/main/system/etc/systemd/system/suspend-sedation.service).

Happy powersave everyone 💻.
