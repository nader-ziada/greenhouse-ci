﻿$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

push-location windows2016fs-release
  git config core.filemode false
  git submodule foreach --recursive git config core.filemode false

  ./scripts/create-release.ps1

  $expected_version=(cat VERSION)
  $created_version=(bosh int "dev_releases/windows2016fs/windows2016fs-$expected_version.yml" --path "/version")
  $uncommitted_changes=(bosh int "dev_releases/windows2016fs/windows2016fs-$expected_version.yml" --path "/uncommitted_changes")
pop-location

if ($expected_version -ne $created_version) {
  echo "**ERROR** expected version: $expected_version, got: $created_version"
  exit 1
}

if ($uncommitted_changes -ne "false") {
  echo "**ERROR** found uncommited changes"
  exit 1
}
