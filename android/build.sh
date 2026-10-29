#!/bin/bash
set -e
ulimit -v unlimited

export JAVA_HOME=/scratch/work/jdk
export PATH=$JAVA_HOME/bin:$PATH
ANDROID_HOME=/scratch/work/android-sdk
BT=$ANDROID_HOME/build-tools/34.0.0
PLAT=$ANDROID_HOME/platforms/android-34/android.jar
cd /scratch/work/apk

rm -rf build && mkdir -p build/compiled build/classes build/gen

echo "== aapt2 compile =="
$BT/aapt2 compile --dir res -o build/res.zip

echo "== aapt2 link =="
$BT/aapt2 link -o build/base.apk \
  -I "$PLAT" \
  --manifest AndroidManifest.xml \
  -A assets \
  --java build/gen \
  --min-sdk-version 24 --target-sdk-version 34 \
  --version-code 1 --version-name 1.0 \
  build/res.zip

echo "== javac =="
javac -nowarn -source 8 -target 8 -classpath "$PLAT" -d build/classes \
  java/com/harsh/imagetopdf/MainActivity.java \
  build/gen/com/harsh/imagetopdf/R.java 2>&1 | grep -v 'bootstrap class path' || true
ls build/classes/com/harsh/imagetopdf/

echo "== d8 =="
$BT/d8 --lib "$PLAT" --min-api 24 --output build/ $(find build/classes -name '*.class')

echo "== package =="
cd build
cp base.apk unaligned.apk
zip -q -j unaligned.apk classes.dex
$BT/zipalign -f -p 4 unaligned.apk aligned.apk

if [ ! -f keystore.jks ]; then
  keytool -genkeypair -keystore keystore.jks -alias imagetopdf \
    -storepass imagetopdf -keypass imagetopdf \
    -keyalg RSA -keysize 2048 -validity 10950 \
    -dname "CN=Image to PDF, OU=Mobile, O=Harsh, L=India, ST=India, C=IN" >/dev/null 2>&1
fi

echo "== sign =="
$BT/apksigner sign --ks keystore.jks --ks-key-alias imagetopdf \
  --ks-pass pass:imagetopdf --key-pass pass:imagetopdf \
  --v1-signing-enabled true --v2-signing-enabled true \
  --out ImageToPDF.apk aligned.apk

echo "== verify =="
$BT/apksigner verify --verbose ImageToPDF.apk | head -12
$BT/aapt2 dump badging ImageToPDF.apk | head -6
ls -lh ImageToPDF.apk
