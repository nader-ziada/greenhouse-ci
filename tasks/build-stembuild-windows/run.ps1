$ErrorActionPreference = "Stop";
trap { Exit 1 }

# Instead of retooling the job/pipeline, use a copy of the old makefile
Copy-Item ci/tasks/build-stembuild-windows/old-Makefile stembuild/Makefile -Recurse -Force

$ROOT_DIR=Get-Location
$OUTPUT_DIR=Join-Path $ROOT_DIR output
$VERSION=Get-Content (Join-Path (Join-Path $ROOT_DIR version) version)

$env:GOPATH = $GO_DIR
Write-Host "GOPATH: $env:GOPATH"
New-Item $GO_DIR -ItemType Directory
$env:PATH="${GO_DIR}/bin;$env:PATH"

$env:PATH += ";c:\var\vcap\packages\git\usr\bin"

Write-Host ***Building Stembuild***
Set-Location stembuild

$INPUT_ZIP_GLOB=Join-Path $ROOT_DIR $env:STEMCELL_AUTOMATION_ZIP
$RENAMED_ZIP_PATH=Join-Path $ROOT_DIR "StemcellAutomation.zip"

Copy-Item -Path $INPUT_ZIP_GLOB $NEW_STEMCELL_AUTOMATION_ZIP -Recurse -Force

Write-Host "Using stemcell automation script: $NEW_STEMCELL_AUTOMATION_ZIP"
make CGO_ENABLED=0 STEMCELL_VERSION=${VERSION} COMMAND=out/stembuild.exe AUTOMATION_PATH=${RENAMED_ZIP_PATH} build

Write-Host ***Copying stembuild to output directory***
Copy-Item out/stembuild.exe $OUTPUT_DIR/stembuild-windows-x86_64-$VERSION.exe
