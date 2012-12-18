selenium-dsl
============
DSL for selenium

Using headless browser (Mac), you can change from "firefox" to "phantomjs"

```
> brew install phantomjs
> git clone https://github.com/detro/ghostdriver.git
> phantomjs ghostdriver/src/main.js
Ghost Driver running on port 8080
```

install:

```
gem installl selenium-dsl
```

create file: 

```
go-wharsojo
```

```
firefox
visit http://google.com
:q=github wharsojo
:btnG~click
li.g[1]>a~click
```

headless(change "firefox" to "remote"):

````
remote http://localhost:8080
````

run it: 

```
sd go-wharsojo -v
```

or
chrome(change "firefox" to "chrome"):

```
$google     = visit http://google.com
$search     = :q=$0
$submit     = :btnG~click
$pick_first = li.g[1]>a~click

chrome
$google
$search github wharsojo
$submit
$pick_first
```

commandline

```
Selenium DSL 
============
> selenium-dsl <script-file>  [-dmqv] #OR
> sd <script-file>  [-mqv] 
--------------------------
m: mono    --> no color
q: quit    --> closing browser
s: screenshot> error, screenshot!
v: verbose --> parsing output 

Script-Reference:
-----------------
eng: <string> [params]    --> Commands
 ex: firefox
     visit http://google.com
     *browser: (firefox | chrome | remote | phantomjs)*
cmd: <css-cmd>            --> DOM Query (DQ)
 ex: li.g[1]>a
cmd: <css-cmd>[=<value>]  --> DQ and attr value=Id0123
 ex: :input_id=Id0123       # <input name="input_id"/>
cmd: <css-cmd>[~<action>] --> DQ and action (DQA)
 ex: li.g[1]>a~click
cmd: <css-cmd>[~<action>][=~<text>] --> DQA and check node text
 ex: li.g[1]>a~text=~Home
cmd: <css-cmd>[@<attr>][=~<text>] --> DQ and check node attr
 ex: :input_id@value=~ayam

Script-BASH-for-cron-job
------------------------
#!/bin/bash
txt=`sd my-website -mqs`
if [ $? -ne 0 ]
  then
    echo "Error!!!"
    echo -e "\r\n $txt"   > elog.txt
    cat emsg.txt elog.txt > email.txt
    ssmtp site.monitor@gmail.com < email.txt
  else echo "OK"
fi

https://github.com/wharsojo/selenium-dsl - Enjoy!!! 
```

reference:

```
http://code.google.com/p/selenium/downloads/list
http://code.google.com/p/selenium/wiki/RubyBindings
http://code.google.com/p/chromedriver/downloads/list
http://selenium.googlecode.com/svn/trunk/docs/api/rb/Selenium/WebDriver/SearchContext.html
http://selenium.googlecode.com/svn/trunk/docs/api/rb/Selenium/WebDriver/Element.html
http://selenium.googlecode.com/svn/trunk/docs/api/rb/Selenium/Server.html
```

MIT License!