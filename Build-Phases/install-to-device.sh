#!/bin/bash

# Modify this to your device's IP address.

if [[ "$SSH_CONNECTION_MODE" == "NET" ]]; then
IP="192.168.2.95"
PORT="22"
elif [[ "$SSH_CONNECTION_MODE" == "USB" ]]; then
IP="127.0.0.1"
PORT="2222"
fi

# Verify that the build is for iOS Device and not a Simulator.
if [[ "$NATIVE_ARCH" != "i386" && "$NATIVE_ARCH" != "x86_64" ]]; then
# Kill any running instances and remove the app folder.
echo "Removing previous app"
ssh root@$IP -p $PORT "killall ${TARGETNAME}; rm -rf /Applications/${WRAPPER_NAME}"
# Self sign the build.
echo "Signing with ldid"
ldid -S$BUILT_PRODUCTS_DIR/${WRAPPER_NAME}/entitlements.xml $BUILT_PRODUCTS_DIR/${WRAPPER_NAME}/$TARGETNAME
ldid -S $BUILT_PRODUCTS_DIR/${WRAPPER_NAME}/Frameworks/BugfenderSDK.framework/BugfenderSDK
ldid -S $BUILT_PRODUCTS_DIR/${WRAPPER_NAME}/Frameworks/PKHUD.framework/PKHUD
ldid -S $BUILT_PRODUCTS_DIR/${WRAPPER_NAME}/Frameworks/SideMenu.framework/SideMenu
ldid -S $BUILT_PRODUCTS_DIR/${WRAPPER_NAME}/Frameworks/FileBrowser.framework/FileBrowser
ldid -S $BUILT_PRODUCTS_DIR/${WRAPPER_NAME}/Frameworks/XLActionController.framework/XLActionController
ldid -S $BUILT_PRODUCTS_DIR/${WRAPPER_NAME}/Frameworks/PopupDialog.framework/PopupDialog
ldid -S $BUILT_PRODUCTS_DIR/${WRAPPER_NAME}/Frameworks/DynamicBlurView.framework/DynamicBlurView

# Copy it over.

#rm -r $BUILT_PRODUCTS_DIR/${WRAPPER_NAME}/Frameworks/libswift*

echo "Copying to device"
scp -P $PORT -r $BUILT_PRODUCTS_DIR/${WRAPPER_NAME} root@$IP:/Applications/

if [[ "$RUN_UICACHE" == "YES" ]]; then
echo "Running uicache"
ssh root@$IP -p $PORT "uicache"
fi

if [[ "$OPEN_APP" == "YES" ]]; then
echo "opening app"
ssh root@$IP -p $PORT "open fi.flodin.ToneManager"
fi

# This part just creates create an OS X notification to let you know that the process is done.
# You can get terminal-notifier from https://github.com/alloy/terminal-notifier.
# You can remove this line if you want.
fi
