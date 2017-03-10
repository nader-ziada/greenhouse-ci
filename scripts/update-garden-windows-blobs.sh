#!/bin/bash
set -ex

sha=$(ls garden-windows-bosh-artifacts/*.zip | sed s/.*-// | sed s/\.zip\//)
unzip -d garden-artifacts garden-windows-bosh-artifacts/*.zip
tar -czf garden-windows-$sha.tgz -C garden-artifacts/bosh-executables .

pushd release

bosh add blob ../garden-windows-$sha.tgz garden-windows
oldBlob=$(cat config/blobs.yml | grep garden-windows | sed s/://)
bosh remove blob $oldBlob

if [ -n "$ACCESS_KEY_ID" -a -n "$SECRET_ACCESS_KEY" ]; then
  cat > config/private.yml << EOF
---
blobstore:
  s3:
    access_key_id: $ACCESS_KEY_ID
    secret_access_key: $SECRET_ACCESS_KEY
EOF
  bosh -n upload blobs
  git config user.email "cf-netgarden-eng@pivotal.io"
  git config user.name "CI (Automated)"
  git commit config/blobs.yml -m "Update Windows bosh blobs"
else
  echo "No \$ACCESS_KEY_ID and \$SECRET_ACCESS_KEY provided, skipping blob upload/commit"
fi

popd

git clone release release-output
