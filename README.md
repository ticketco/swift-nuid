[![License Apache 2](https://img.shields.io/badge/License-Apache2-blue.svg)](https://www.apache.org/licenses/LICENSE-2.0)
[![Build Status](https://github.com/Jarema/swift-nuid/actions/workflows/main.yml/badge.svg?branch=main)](https://github.com/Jarema/swift-nuid/actions)

# swift-nuid

A highly performant unique identifier generator.

## Reason for fork

This [original version](https://github.com/Jarema/swift-nuid) of this library is build for mac-os. To support Docker and AWS we need an linux version of this library. This is an dependency for [swift.nats](https://github.com/nats-io/nats.swift) which is the dependency of [Thea push notification backend service](https://github.com/ticketco/Thea_PushNotification_BackendService).

## How to test the linux version

Simply run all the tests on the Linux environment. We can use Docker to simulate the Linux environment. For this purpose a Docker file is introduced. Now to run all the tests, copy and run the following commands in your favorite terminal.

- Open `Docker Desktop`
- Navigate to the current base directory in your terminal, `..../swift-nuid/`
- build the docker image, `docker build -t swift-nuid-test .`
- run the container to execute all the tests, `docker run -it swift-nuid-test`

The above will run all the existing tests in the linux environment.


### Note
As the tests are run on Linux environment, sometimes the tests get stalled. In this case exit the current command and start again to resume.

 
