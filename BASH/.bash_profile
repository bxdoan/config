export LC_ALL='en_US.UTF-8'
export LANG='en_US.UTF-8'

[[ -f ~/.bashrc ]] && source ~/.bashrc

for file in ~/.{path,bash_prompt,exports,aliases,functions,extra}; do
	[ -r "$file" ] && [ -f "$file" ] && source "$file";
done;
unset file;export L1URL=https://eth-mainnet.g.alchemy.com/v2/coTmbEFOlZw3viWFsPeWcjOgdAPR7Afj
export PATH=$PATH:/usr/local/go/bin
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
export PATH="/opt/homebrew/opt/mysql-client/bin:$PATH"
