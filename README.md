# Cow

Cow - console server wrapper. 

## Installation

`gem install cow`

`sudo cow add [hostname] [type] [community]`

## Usage

Type `cow`. Then you can see usage.

`cow update` should be run periodically.

## Example

```
$ cow list
SERVER/PORT                    PORTNAME             COMMAND
console.local/1                tokyo-core01         ssh -l kazubu:7001 console.local
console.local/2                tokyo-core02         ssh -l kazubu:7002 console.local
console.local/3                tokyo-sw01           ssh -l kazubu:7003 console.local
console.local/4                tokyo-sw02           ssh -l kazubu:7004 console.local
console.local/5                tokyo-serv01         ssh -l kazubu:7005 console.local
console.local/6                tokyo-serv02         ssh -l kazubu:7006 console.local
console.local/7                tokyo-serv03         ssh -l kazubu:7007 console.local

$ cow find core
SERVER/PORT                    PORTNAME             COMMAND
console.local/1                tokyo-core01         ssh -l kazubu:7001 console.local
console.local/2                tokyo-core02         ssh -l kazubu:7002 console.local

$ cow connect tokyo-core01
Found on console.local/1. Connecting...
Password:

tokyo-core01 (ttyd0)

login: 
```

## Pico integration with Zsh

In .zshrc:
```
function peco-select-console() {
  BUFFER=$(cow list | \
           peco --query "$LBUFFER" | \
           awk 'BEGIN{FS=" "}{print "cow c "$2}')
  CURSOR=$#BUFFER
  zle clear-screen
}

zle -N peco-select-console
bindkey '^xc' peco-select-console
```

Press Ctrl-X C then you can select a port with interactive filtering.
