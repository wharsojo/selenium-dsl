selenium-dsl
============
Simple-dsl for selenium

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

run it: 

```
sd go-wharsojo
```

Not Yet Implement

```
$google     = visit http://google.com
$search     = :q=$0
$submit     = :btnG~click
$pick_first = li.g>a~click
$git_author = span.author>a[1]~click
$git_repo   = li.public.source[$0]>h3>a~click
$flash_eq   = div.flash~text->$0

$google
$search github wharsojo
$submit
$pick_first
$git_author
$git_repo 1
$flash_eq Aloha
```

MIT License!