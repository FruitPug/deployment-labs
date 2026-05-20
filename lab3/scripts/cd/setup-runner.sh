#!/bin/bash

set -e

echo "== Updating system =="
apt update 
apt upgrade -y

echo "== Installing packages =="
apt install -y curl git docker.io

echo "== DONE =="
