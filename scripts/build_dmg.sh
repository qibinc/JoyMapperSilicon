#!/bin/bash

# Codesign and build a dmg file

if [ $# -lt 1 ]; then
  echo "usage: $0 <app_path>"
  exit 1
fi

SRC_APP_PATH="${1}"
APP_NAME=`basename "${SRC_APP_PATH}"`
if [ "${APP_NAME}" != "JoyKeyMapper.app" ]; then
  echo "error: App name must be 'JoyKeyMapper.app'"
  exit 2
fi

echo "Source app path: ${SRC_APP_PATH}"

PROJECT_ROOT="`dirname $0`/.."
TMP_DIR="${PROJECT_ROOT}/dmg"
APP_PATH="${TMP_DIR}/JoyKeyMapper.app"
LAUNCHER_ENTITLEMENTS="${PROJECT_ROOT}/JoyKeyMapperLauncher/JoyKeyMapperLauncher.entitlements"
APP_ENTITLEMENTS="${PROJECT_ROOT}/JoyKeyMapper/JoyKeyMapper.entitlements"
DMG_PATH="${TMP_DIR}/JoyKeyMapper.dmg"
BUNDLE_ID="jp.0spec.JoyKeyMapper"

if [ "${APP_API_USER}" == "" ]; then
  read -p "App Connect User: " APP_API_USER
fi

if [ "${APP_API_ISSUER}" == "" ]; then
  read -p "App Connect Issuer: " APP_API_ISSUER
fi

if [ "${APP_API_KEY_ID}" == "" ]; then
  read -p "App Connect Key ID: " APP_API_KEY_ID
fi

# Copy App
echo "Copying app..."
rm -rf "${TMP_DIR}"
mkdir "${TMP_DIR}"
cp -Rp "${SRC_APP_PATH}" "${APP_PATH}"

# Codesign
echo "Codesigning..."
codesign -f -o runtime --timestamp -s "Developer ID Application" "${APP_PATH}/Contents/Library/LoginItems/JoyKeyMapperLauncher.app" --entitlements "${LAUNCHER_ENTITLEMENTS}"
if [ $? -ne 0 ]; then
  echo "error: Failed to sign to the helper app"
  exit 1
fi

codesign -f -o runtime --timestamp -s "Developer ID Application" "${APP_PATH}/Contents/Frameworks/JoyConSwift.framework" --entitlements "${APP_ENTITLEMENTS}"
if [ $? -ne 0 ]; then
  echo "error: Failed to sign to the framework"
  exit 2
fi

codesign -f -o runtime --timestamp -s "Developer ID Application" "${APP_PATH}" --entitlements "${APP_ENTITLEMENTS}"
if [ $? -ne 0 ]; then
  echo "error: Failed to sign to the app"
  exit 3
fi

# Verify
echo "Verifying..."
codesign -dv --verbose=4 "${APP_PATH}"
if [ $? -ne 0 ]; then
  echo "error: The app is not correctly signed"
  exit 4
fi

# Create a dmg file
echo "Creating a dmg file at ${DMG_PATH}"
dmgbuild -s "${PROJECT_ROOT}/scripts/dmg_settings.py" JoyKeyMapper "${DMG_PATH}"
if [ $? -ne 0 ]; then
  echo "error: Failed to build a dmg file"
  exit 5
fi

echo "Code signing to the dmg file..."
codesign -f -o runtime --timestamp -s "Developer ID Application" "${DMG_PATH}"
if [ $? -ne 0 ]; then
  echo "error: Failed to sign to the dmg file"
  exit 6
fi

# Notarize
echo "Notarizing the dmg file..."
RESULT=`xcrun altool --notarize-app \
  --primary-bundle-id "${BUNDLE_ID}" \
  -u "${APP_API_USER}" \
  --apiKey "${APP_API_KEY_ID}" \
  --apiIssuer "${APP_API_ISSUER}" \
  -t osx -f "${DMG_PATH}"`

echo "${RESULT}"
REQUEST_UUID=`echo "${RESULT}" | grep "RequestUUID = " | sed "s/RequestUUID = \(.*\)$/\1/"`
if [ "${REQUEST_UUID}" == "" ]; then
  echo "error: Failed to notarize the dmg file"
  exit 7
fi

echo "Waiting for the approval..."
echo "It would take few minutes"
RETRY=20
APPROVED=false
for i in `seq ${RETRY}`; do
  sleep 30
  RESULT=`xcrun altool --notarization-history 0 \
    -u "${APP_API_USER}" \
    --apiKey "${APP_API_KEY_ID}" \
    --apiIssuer "${APP_API_ISSUER}"`
  STATUS=`echo "${RESULT}" | grep "${REQUEST_UUID}" | cut -f 5- -d " "`

  if `echo "${STATUS}" | grep "Package Approved" > /dev/null`; then
    APPROVED=true
    break
  elif [ "${STATUS}" == "" ]; then
    echo "waiting for updating the notarization history..."
  elif `echo "${STATUS}" | grep "in progress" > /dev/null`; then
    echo "in progress..."
  else
    echo "${RESULT}"
    echo "error: Invalid notarization status: ${STATUS}"
    exit 8
  fi
done

echo "${RESULT}"
if [ ${APPROVED} = false ] ; then
  echo "error: Approval timeout"
  exit 9
fi

# Staple a ticket to the dmg file
xcrun stapler staple "${DMG_PATH}"
if [ $? -ne 0 ]; then
  echo "error: Failed to staple a ticket"
  exit 10
fi

echo "Done.\n"
