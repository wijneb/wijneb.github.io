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

alias @@ral='alias | grep rofi'
alias @@rf='rofi -show drun'
alias @@rfh='history | rofi -dmenu'
alias @@rfa='alias | rofi -dmenu'
alias @@rfs='rofi -show drun -show-icons -theme windows11-list-dark.rasi'

alias @@dl='distroboxlist'
alias @@ds='distrobox stop -a -Y'

alias @@psa='podman ps -a --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Image}}"'
alias @@psas='podman ps -a --format "table {{.Names}}\t{{.Status}}"'  
alias @@pil='podman image list'
alias @@pils='podman image list --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"'
alias @@xpb='podman build -t alpi .'
alias @@xpr='podman run -it alpi'
alias @@prl='podman rm -l'
alias @@pkl='podman kill -l'
alias @@pka='podman kill -a'
alias @@xprmi='podman rmi alpi'
alias @@pal='alias | grep podman'
alias @@xprdp='podman run -dt -p 3389:3389 --hostname alp --name alprdp alpi'
alias @@rdp='rdesktop localhost'
alias @@rdpf='rdesktop -f localhost'

alias @@xx='podman start dbrdp; sleep 2; rdesktop -f -u abc -p abc localhost'

alias lx='ls -al'
