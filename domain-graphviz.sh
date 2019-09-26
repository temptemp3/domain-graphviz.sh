#!/bin/bash
## domain-graphviz
## - reads from file domains creates png graphviz
## version 0.1.2 - test lookup-domain-names
##################################################
. ${SH2}/aliases/commands.sh
. ${SH2}/cecho.sh
. ${SH2}/gt.sh
. ${SH2}/build.sh
strip-comments() {
  sed -e 's/#.*//' -
}
car() { echo "${1}" ; }
cdr() { echo "${@:2}" ; }
store-initialize() {
  store["generation"]=0
  store["domains_sha1sum"]=0
  store["domains"]=""
  declare -p store &>/dev/null
}
store-persist() {
  store[domains_sha1sum]=${domains_sha1sum}
  store[generation]=$(( store[generation] + 1 ))
  store[domains]=${domains}
  declare -p store | tee domain-graphviz-store &>/dev/null
}
store-set() {
  true
}
store-get() {
  true
}
store() {
  commands
}
generate-dot() {
  cat ${temp}-domains | gawk '
BEGIN {
  print "digraph G {"
  known_host["183.181.90.41"]="minoori (xserver)"
  known_host["8.8.8.8"]="dns.google"
  known_host["202.172.28.60"]="s59.coreserver.jp"
}
{
  if(!hash[$(2)]) {
    ip[++ip[0]]=$(2)
    hash[$(2)]=ip[0]
  }
  host[$(2)]=$(1) "\n" host[$(2)] 
  ++count[$(2)]
}
END {
  #print ip[0]
  for(i=1;i<ip[0];i++) {
    #if(known_host[ip[i]]) print ip[i] " " known_host[ip[i]] " (" count[ip[i]] ")" 
    #else print ip[i] " (" count[ip[i]] ")" 
    split(host[ip[i]],hosts)
    for(j=1;j<=length(hosts);j++) {
      print "\"" ip[i] "\" -> \"" hosts[j] "\" ; "
    }

  }
  print "}"
}
'
}
generate() {
  commands
}
domains-renew() {

  cecho green "looking up host ips ..."
  {
    lookup-domain-names \
    | tee domain-lookup \
    | tee ${temp}-domains
  } &>/dev/null
  cecho green "done looking up host ips"

  cecho green "performing reverse ip lookup ..."
  ips=$( cat domain-lookup | cut '-d ' '-f2' | sort -u )
  for ip in ${ips}
  do
   host=$( dig -x ${ip} | grep -v -e '^;' | grep PTR | cut '-f3-4' | tr --delete '\t' | sed 's/^PTR//'  )
   test ! "${host}" || {
     echo "${host} ${ip}"
   }
  done | tee -a domain-lookup | tee -a ${temp}-domains
  cecho green "done performing reverse ip lookup"

  test -f "domain-lookup-last" || touch ${_}
  icdiff domain-lookup{,-last} || exit
  cp -v domain-lookup{,-last}

}
domains() {
  commands
}
temp-cleanup() {
  test ! "${temp}" || {
    cecho yellow "$( rm -rvf ${temp}* )"
  }
}
lookup-domain-names() {
  dig ${domains} \
  | grep -v -e '^\s*$' -e '^;' -e 'SOA' \
  | gawk '{print $(1) " " $(5)}' \
  | sort
}
domain-names() {
  cat domains \
  | strip-comments \
  | tr --delete '\r' \
  | xargs
}
initialize-domains() {
  domains=$( domain-names )
}
initialize-temp() {
  temp=$( mktemp )
}
initialize() {
  ${FUNCNAME}-domains
  ${FUNCNAME}-temp
}
domain-graphviz-build() {
  build=build
  build true
}
domain-graphviz-true() {
  true
}
domain-graphviz-main() {
  local temp
  local domains_sha1sum
  local domains

  test -f "domains" || return

  test -d "generation" || mkdir -pv ${_}

  cecho green "initializing ..."
  initialize
  cecho green "done initializing"

  test ! -f "domain-graphviz-store" && {
    touch ${_}
  } || {
    . ${_}
    cecho green "loading store ..."
    sleep 1
    cecho green "done loading store"
  }

  cecho green "initializing store ..."  
  declare -p store 2>/dev/null || { 
    declare -A store
    store initialize
  }
  cecho green "done initializing store"  

  cecho green "renewing domains ..."
  domains renew
  cecho green "done renewing domains"

  domains_sha1sum=$( car $( sha1sum ${temp}-domains ) )
  test ! "${store[domains_sha1sum]}" = "${domains_sha1sum}" || {
    cecho yellow "domains unchanged"
    temp-cleanup
    return
  }

  cecho green "generating dot ..."
  generate dot | tee domains-dot | tee ${temp}-domains.dot &>/dev/null
  fdp -Tpng -o generation/${store[generation]}.png  ${temp}-domains.dot
  cecho green "done generating dot"

  cecho green "persisting store ..."
  store persist
  cecho green "done persiting store"
 
  temp-cleanup 
}
domain-graphviz-test-lookup-domain-names() {
  domains=$( cat /dev/clipboard | xargs -i echo -n "{} " | tr --delete '\r' )
  echo ${domains}
  lookup-domain-names
}
domain-graphviz-test() {
  commands
}
domain-graphviz() {
  commands
}
##################################################
if [ ! ] 
then
 true
else
 exit 1 # wrong args
fi
##################################################
domain-graphviz ${@}
##################################################
## generated by create-stub2.sh v0.1.2
## on Thu, 19 Sep 2019 13:56:19 +0900
## see <https://github.com/temptemp3/sh2>
##################################################
