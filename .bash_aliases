alias @@ial='alias | grep incus'
alias @@ix='incusstop'
alias @@il='incus list  -c stnm4'
alias @@ilc='incus list  -c stnm4 | grep CON'
alias @@ilv='incus list  -c stnm4 | grep VIR'

alias @@iil='incus image list -c tdfs'
alias @@iilc='incus image list -c tdfs | grep CON'
alias @@iilv='incus image list -c tdfs | grep VIR'

alias @@st='sudo ncdu /var/lib/incus/storage-pools/default'

alias @@rd='ramdisk | column -ts " "'

alias @@rf='rofi -show drun'

alias @@dl='distroboxlist'
alias @@ds='distrobox stop -a -Y'

alias @@psa='podman ps -a --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Image}}"'
alias @@pil='podman image list'
alias @@pba='podman build -t alpi .'
alias @@pra='podman run -it alpi'
alias @@prl='podman rm -l'
alias @@pkl='podman kill -l'
alias @@prmi='podman rmi alpi'
alias @@pal='alias | grep podman'
alias @@prdp='podman run -dt -p 3389:3389 --hostname alp --name alprdp alpi'
alias @@rdp='rdesktop localhost'
alias @@rdpf='rdesktop -f localhost'

alias lx='ls -al'
