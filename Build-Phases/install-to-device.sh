#!/bin/bash

# Modify this to your device's IP address.

if [[ "$SSH_CONNECTION_MODE" == "NET" ]]; then
IP="192.168.2.95"
PORT="22"
else
IP="127.0.0.1"
PORT="2222"
fi

# Verify that the build is for iOS Device and not a Simulator.
if [[ "$NATIVE_ARCH" != "i386" && "$NATIVE_ARCH" != "x86_64" ]]; then

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

#rm -r $BUILT_PRODUCTS_DIR/${WRAPPER_NAME}/Frameworks/libswift*

# DEB
if [[ "$CREATE_DEB" == "YES" ]]; then
echo "Preparing deb archive"
cd ~/Documents/Projects/Tweaks/
rm -r BUILD
mkdir -p BUILD/Applications
cp -R $BUILT_PRODUCTS_DIR/${WRAPPER_NAME} BUILD/Applications/
cp -R ToneManager/layout/DEBIAN BUILD/

INFO_PLIST_PATH=BUILD/Applications/ToneManager.app/Info.plist
version=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "${INFO_PLIST_PATH}")
build=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "${INFO_PLIST_PATH}")

echo "Version: ${version}-${build}"
echo "Version: ${version}-${build}" >> BUILD/DEBIAN/control

rm -r BUILD/Applications/${WRAPPER_NAME}/Frameworks/libswift*
rm -r BUILD/Applications/${WRAPPER_NAME}/libswift*
find ~/Documents/Projects/Tweaks/ -name ".DS_Store" -depth -exec rm {} \;

dpkg-deb -bZgzip BUILD ToneManager/
cp ToneManager/*.deb ToneManager/packages/

#install
echo "Installing deb"
ssh root@$IP -p $PORT "mkdir -p /var/mobile/Documents/tmpdeb"
scp -P $PORT -r ToneManager/*.deb root@$IP:/var/mobile/Documents/tmpdeb/
ssh root@$IP -p $PORT "dpkg -i /var/mobile/Documents/tmpdeb/*.deb"
ssh root@$IP -p $PORT "apt-get install -f -y"
ssh root@$IP -p $PORT "rm -r /var/mobile/Documents/tmpdeb"

#repo
echo "Updating cydia repo"
cd ~/Documents/GitHub/jesperflodin1.github.io/
cp ~/Documents/Projects/Tweaks/ToneManager/packages/*.deb debs
dpkg-scanpackages -m ./debs > Packages
bzip2 -fks Packages

echo "Updating depiction version"
xmlstarlet ed --inplace -O -P -u "/package/version" -v "${version}-${build}" "depictions/fi.flodin.tonemanager/info.xml"

git add .
git commit -m 'updated ToneManager'
git push
cd -

rm ToneManager/*.deb
echo "Done!"

else

# Kill any running instances and remove the app folder.
echo "Removing previous app"
ssh root@$IP -p $PORT "killall ${TARGETNAME}; rm -rf /Applications/${WRAPPER_NAME}"


# Copy it over.

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
fi

fi
