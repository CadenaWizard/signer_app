#!/bin/bash

# Script to select the appropriate library based on the build target
# This script is called by the podspec to choose the right library

if [ "$CONFIGURATION" = "Debug" ] && [ "$PLATFORM_NAME" = "iphonesimulator" ]; then
    # Debug simulator - use simulator library
    echo "Using simulator library for Debug simulator build"
    cp "$PODS_TARGET_SRCROOT/Classes/simulator/libdlcplazacryptlib.a" "$PODS_TARGET_SRCROOT/Classes/libdlcplazacryptlib_selected.a"
elif [ "$CONFIGURATION" = "Release" ] && [ "$PLATFORM_NAME" = "iphonesimulator" ]; then
    # Release simulator - use simulator library  
    echo "Using simulator library for Release simulator build"
    cp "$PODS_TARGET_SRCROOT/Classes/simulator/libdlcplazacryptlib.a" "$PODS_TARGET_SRCROOT/Classes/libdlcplazacryptlib_selected.a"
else
    # Device builds - use device library
    echo "Using device library for device build"
    cp "$PODS_TARGET_SRCROOT/Classes/device/libdlcplazacryptlib.a" "$PODS_TARGET_SRCROOT/Classes/libdlcplazacryptlib_selected.a"
fi


