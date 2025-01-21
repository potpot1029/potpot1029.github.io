#!/bin/bash

# from https://github.com/satnaing/astro-paper/issues/53
if [[ $# > 1 ]]; then
  echo "one argument is allowed: file name"
  exit
fi

if [[ -z $1 ]]; then
  fname="a-TEMPLATE-post"
else
  fname=$(basename "$1")
fi


time=$(date +"%Y-%m-%dT%T%+08:00")

frontmatter=$(cat << EOM
---
author: Joey Chau
pubDatetime: $time
modDatetime: 
title: 
slug: $(basename $1)
featured: true
draft: true
tags:
  - 
description:
---
EOM
)

markdown="${frontmatter}

"


echo "$markdown" > ./src/content/blog/$fname.md

echo "Markdown file generated！"