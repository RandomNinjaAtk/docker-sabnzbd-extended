#!/usr/bin/env python

import os
import sys
import logging
import configparser
import xml.etree.ElementTree as ET

autoProcess = "/config/scripts/configs/autoProcess.ini"

def main():
   
    safeConfigParser = configparser.ConfigParser()
    safeConfigParser.read(autoProcess)

    # Set Converter Settings
    safeConfigParser.set("Converter", "ffmpeg", "ffmpeg")
    safeConfigParser.set("Converter", "ffprobe", "ffprobe")
    safeConfigParser.set("Converter", "hwaccels", " ")
    safeConfigParser.set("Converter", "hwaccel-decoders", " ")
                            
    fp = open(autoProcess, "w")
    safeConfigParser.write(fp)
    fp.close()


if __name__ == '__main__':
    main()
