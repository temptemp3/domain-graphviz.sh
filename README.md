# domain-graphviz.sh
Creates png graphviz image from file containing list of domain names

## requirements

+ bind9 (https://www.isc.org/download/) 
  + dig
+ graphviz (https://www.graphviz.org/download/)
  + fdp

## quickstart

```
{
  git clone https://github.com/temptemp3/domain-graphviz.sh.git
  (
    cd $( basename ${_} .git )
    echo google.com >> domains
    echo yahoo.com >> domains
    echo wikipedia.org >> domains
    bash domain-graphviz.sh
  )
}
```
