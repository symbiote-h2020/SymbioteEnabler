#!/bin/sh

echo "Loading images"

echo "Loading rabbitmq"
docker load -i images/rabbitmq.tar

echo "Loading mongo"
docker load -i images/mongo.tar

echo "Loading symbiote-enablerconfig"
docker load -i images/symbiote-enablerconfig.tar

echo "Loading symbiote-aam"
docker load -i images/symbiote-aam.tar

echo "Loading symbiote-eureka"
docker load -i images/symbiote-eureka.tar

echo "Loading symbiote-rap"
docker load -i images/symbiote-rap.tar

echo "Loading symbiote-rh"
docker load -i images/symbiote-rh.tar

echo "Loading symbiote-monitoring"
docker load -i images/symbiote-monitoring.tar

echo "Loading symbiote-erm"
docker load -i images/symbiote-erm.tar

echo "Loading symbiote-epp"
docker load -i images/symbiote-epp.tar

echo "Loading symbiote-enablerlogicexample"
docker load -i images/symbiote-enablerlogicexample.tar

echo "Loading symbiote-rappluginexample"
docker load -i images/symbiote-rappluginexample.tar

echo "Loading symbiote-nginx"
docker load -i images/symbiote-nginx.tar
