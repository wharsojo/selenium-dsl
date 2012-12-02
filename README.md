selenium-dsl
============
DSL for selenium

Using headless browser (Mac), you can change from "firefox" to "remote"

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
li.g>a~click
span.author>a[1]~click     
li.public.source[1]>h3>a~click
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

```
$google     = visit http://google.com
$search     = :q=$0
$submit     = :btnG~click
$pick_first = li.g>a~click
$git_author = span.author>a[1]~click
$git_repo   = li.public.source[$0]>h3>a~click

chrome
$google
$search github wharsojo
$submit
$pick_first
$git_author
$git_repo 1
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