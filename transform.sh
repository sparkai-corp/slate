#!/bin/sh

# These are transformations to make up for Widdershins having serious flaws in conversion of yaml to swagger

sed -i '' 's/vundefined/documentation/g' source/index.html.md
sed -i '' 's/# Introduction//g' source/index.html.md
# Important! This removes the title which, if not done,  breaks everything downstream due to bugs in Slate
sed -i '' 's/<h1 id="">SparkAI.*$/# Introduction/g' source/index.html.md

sed -i '' '1,/\`\`\`/{s/\`\`\`/\`\`\`python/;}' source/index.html.md

sed -i '' 's/Base URLs.*//g' source/index.html.md
sed -i '' 's/\* <a href.*<\/a>//g' source/index.html.md

sed -i '' 's/# Authentication//g' source/index.html.md
sed -i '' 's/- HTTP Authentication.*//g' source/index.html.md
sed -i '' 's/A supplied API token//g' source/index.html.md
sed -i '' 's/A supplied API token//g' source/index.html.md

