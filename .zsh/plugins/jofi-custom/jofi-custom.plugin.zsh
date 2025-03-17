# echo "Loading jofi-custom plugin..."

# Add completions to fpath
fpath=("${0:h}/functions" "${0:h}/completions" $fpath)
# Load and compile completion files
autoload -U compinit && compinit

# Force load all functions and completions immediately
for dir in functions; do
  for file in "${0:h}/$dir"/*(:t); do
    if [ -f "${0:h}/$dir/$file" ]; then
      autoload -U +X "${0:h}/$dir/$file"
      # echo "Force loaded $dir: $file"
    fi
  done
done

# Source all zsh files from the zsh directory
for file in "${0:h}/zsh"/*.zsh; do
  source "$file"
done