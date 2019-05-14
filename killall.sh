#!/bin/bash
ps  -efww|grep skynet|grep -v grep|cut -c 9-15|xargs kill -9
