#!/bin/bash

docker build -t cqube-minio-image .minio.Dockerfile

docker run -p 9000:9000 --name cqube_minio -d cqube-minio-image
