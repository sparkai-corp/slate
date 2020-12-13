#!/bin/sh

./build.sh
bundle exec middleman build
gsutil cp -r build/* gs://docs.spark.ai
