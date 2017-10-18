#!/usr/bin/env bash

if [[ ! $(uname -v) =~ "Darwin Kernel" ]];
then
  echo "This script only runs on Mac OS (Darwin Kernel) at this time"
  exit 1
fi 

PATH=./node_modules/.bin:${PATH}

gulp clean
gulp build-css
gulp build-assets

rootDir=$(dirname $0)
distDir="${rootDir}/dist/components"

files=$(find $distDir -type f -name "*.css" -not -name "*.min.css")

for file in $files
do
  echo "Building ${file}.js"
  cat<<HERE > "${file}.js"
import { injectGlobal } from 'emotion';
export default injectGlobal\`
$(cat $file | sed -E 's/\`/\\\`/g' | sed -E 's/\\([0-9]+)/\\\\\1/g'  | sed -E 's/\\e/\\\\e/g')
\`;
HERE
  stat -f "%z %N" "${file}.js"
done
