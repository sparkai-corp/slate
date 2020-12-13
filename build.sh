#!/bin/sh

git submodule update --remote --merge
widdershins --version false --search true --language_tabs 'python:Python' 'javascript:Javascript' 'shell:cURL' --summary --expandBody --omitBody sparkai/src/doc/sparkai-public-api.yaml -o ./source/index.html.md
./transform.sh
