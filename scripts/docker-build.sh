#!/bin/bash

# $1 should be a complete tag like okfn/proto-auth:v1.0.0

docker build -t $1 .
