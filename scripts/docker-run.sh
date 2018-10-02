#!/bin/bash

# $1 should refer to a image with tag like proto-auth:v1.0.0

docker run -d -p 3000:3000 $1
