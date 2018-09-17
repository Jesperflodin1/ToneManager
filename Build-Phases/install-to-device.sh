#!/bin/bash

# Modify this to your device's IP address.
IP="192.168.2.95"

# Verify that the build is for iOS Device and not a Simulator.
if [[ "$NATIVE_ARCH" != "i386" && "$NATIVE_ARCH" != "x86_64" ]]; then
# Kill any running instances and remove the app folder.
echo "Removing previous app"
ssh root@$IP "killall ${TARGETNAME}; rm -rf /Applications/${WRAPPER_NAME}"
# Self sign the build.
echo "Signing with ldid"
ldid -S$BUILT_PRODUCTS_DIR/${WRAPPER_NAME}/entitlements.xml $BUILT_PRODUCTS_DIR/${WRAPPER_NAME}/$TARGETNAME
ldid -S $BUILT_PRODUCTS_DIR/${WRAPPER_NAME}/Frameworks/BugfenderSDK.framework/BugfenderSDK
ldid -S $BUILT_PRODUCTS_DIR/${WRAPPER_NAME}/Frameworks/PKHUD.framework/PKHUD
ldid -S $BUILT_PRODUCTS_DIR/${WRAPPER_NAME}/Frameworks/SideMenu.framework/SideMenu
# Copy it over.

#rm -r $BUILT_PRODUCTS_DIR/${WRAPPER_NAME}/Frameworks/libswift*

echo "Copying to device"
scp -r $BUILT_PRODUCTS_DIR/${WRAPPER_NAME} root@$IP:/Applications/
#echo "Running uicache"
#ssh root@$IP "uicache"

echo "opening app"
ssh root@$IP "open fi.flodin.ToneManager"

# This part just creates create an OS X notification to let you know that the process is done.
# You can get terminal-notifier from https://github.com/alloy/terminal-notifier.
# You can remove this line if you want.
fi
