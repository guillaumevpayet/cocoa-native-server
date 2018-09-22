# Cocoa Native Server (XCode project)

## Introduction

This project is a part of a trio of projects:

* [Remote Numpad](https://github.com/theolizard/remote-numpad):
Written in Kotlin, this is the client which runs on an Android device and
sends the user's inputs to the computer.
* [Remote Numpad Server](https://github.com/theolizard/remote-numpad-server):
Written in Kotlin, this is the server that runs on the computer and receives
the inputs from the Android device and simulates the key presses.
* Cocoa Native Server (this project): Written in Objective-C, this is the
Bluetooth server library for MacOS X. It receives the Bluetooth data and
passes it on to the Remote Numpad Server.

## Description

This is a MacOS X library written in Objective-C. It is made up of a single
Objective-C class (*CocoaNativeServer*) which handles the Bluetooth
connection and communicates with the
[Remote Numpad Server](https://github.com/theolizard/remote-numpad-server) via JNI.

## Compilation

This is an XCode project so it can be imported by XCode and then compiled.

## Contributing

This is not a main project for me so help is very apreciated. Anyone is
welcome to contribute to this project (issues, requests, pull requests).
