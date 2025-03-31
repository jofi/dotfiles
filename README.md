# Bootstrapping new computer/vm/account

## Initial Setup by Operating System

### macOS (Darwin)

1. Install Homebrew:

   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

2. Install git and yadm:

   ```bash
   brew install git yadm
   ```

### Linux (Ubuntu)

1. Install git and yadm:

   ```bash
   sudo apt update
   sudo apt install -y git yadm
   ```

### Linux (Rocky)

1. Install git and yadm:

   ```bash
   # Install git
   sudo dnf install -y git

   # Install yadm from source
   git clone https://github.com/TheLocehiliosan/yadm.git /tmp/yadm
   sudo mkdir -p /usr/local/bin
   sudo cp /tmp/yadm/yadm /usr/local/bin/
   sudo chmod +x /usr/local/bin/yadm
   ```

## Yadm clone and bootstrap

```bash
yadm clone https://github.com/jofi/dotfiles.git`
yadm bootstrap
``` 