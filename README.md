selenium-dsl
============
Simple-dsl for selenium

install:

```
gem installl selenium-dsl
```

create file: "go-wharsojo"

```
firefox
visit http://google.com
:q=github wharsojo
:btnG~click
li.g>a~click
span.author>a[1]~click     
li.public.source[1]>h3>a~click
```
run it: "sd go-wharsojo"

MIT License!