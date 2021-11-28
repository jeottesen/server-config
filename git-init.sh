#!/bin/bash
# sets up a pre-commit hook to ensure that vault.yaml is encrypted
#
# credit goes to nick busey from homelabos for this neat little trick
# https://gitlab.com/NickBusey/HomelabOS/-/issues/355

if [ -d .git/ ]; then
rm .git/hooks/pre-commit
cat <<'EOT' >> .git/hooks/pre-commit
#!/bin/bash
DIR="$(cd "$(dirname "$0")" && pwd)"
HOOK_DIR="$(echo $DIR | sed "s#.git/hooks#.git-hooks#")"
bash $HOOK_DIR/pre-commit.sh
EOT

fi

chmod +x .git/hooks/pre-commit