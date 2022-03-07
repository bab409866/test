if [ -z "$ANDROID_NDK" ]; then
    export ANDROID_NDK=~/android-ndk-r10e
fi
MACOSX_DEPLOYMENT_TARGET=10.13
# PATH=/usr/bin:/bin:/usr/sbin:/sbin
# MACOSX_DEPLOYMENT_TARGET=XX.YY make
ANDROID_NDK=/root/work/build_xlua_with_libs/android-ndk-r10e
ANDROID_TOOLCHAIN_NAME=/root/work/build_xlua_with_libs/android-ndk-r10e/toolchains/x86_64-4.8
echo $ANDROID_TOOLCHAIN_NAME

echo $ANDROID_NDK

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SRCDIR=$DIR/luajit-2.1.0b3
# ANDROID_NDK=~/android-ndk-r10e

OS=`uname -s`
PREBUILT_PLATFORM=linux-x86_64
if [[ "$OS" == "Darwin" ]]; then
    PREBUILT_PLATFORM=darwin-x86_64
fi


echo "Building armv7 lib"
NDKVER=$ANDROID_NDK/toolchains/arm-linux-androideabi-4.8  
NDKP=$NDKVER/prebuilt/$PREBUILT_PLATFORM/bin/arm-linux-androideabi-  
NDKARCH="-march=armv7-a -mfloat-abi=softfp -Wl,--fix-cortex-a8"  
NDKABI=14 
NDKF="--sysroot $ANDROID_NDK/platforms/android-$NDKABI/arch-arm"
cd "$SRCDIR"
make clean
make HOST_CC="gcc -m32" CROSS=$NDKP TARGET_SYS=Linux TARGET_FLAGS="$NDKF $NDKARCH"

cd "$DIR"

mkdir -p build_lj_v7a && cd build_lj_v7a
cmake -DUSING_LUAJIT=ON -DANDROID_ABI=armeabi-v7a -DCMAKE_TOOLCHAIN_FILE=../cmake/android.toolchain.cmake -DANDROID_TOOLCHAIN_NAME=arm-linux-androideabi-4.9 -DANDROID_NATIVE_API_LEVEL=android-9 ../ -DCMAKE_BUILD_TYPE=Release 
cd "$DIR"
cmake --build build_lj_v7a --config Release
mkdir -p plugin_luajit/Plugins/Android/libs/armeabi-v7a/
cp build_lj_v7a/libxlua.so plugin_luajit/Plugins/Android/libs/armeabi-v7a/libxlua.so


# exit # 最后还是编辑成功了

echo "Building x86 lib"
NDKVER=$ANDROID_NDK/toolchains/x86-4.8  
NDKP=$NDKVER/prebuilt/$PREBUILT_PLATFORM/bin/i686-linux-android-  
NDKABI=14  
NDKF="--sysroot $ANDROID_NDK/platforms/android-$NDKABI/arch-x86"  
cd "$SRCDIR"
make clean
make HOST_CC="gcc -m32" CROSS=$NDKP TARGET_SYS=Linux TARGET_FLAGS="$NDKF"

cd "$DIR"
mkdir -p build_lj_x86 && cd build_lj_x86
cmake -DUSING_LUAJIT=ON -DANDROID_ABI=x86 -DCMAKE_TOOLCHAIN_FILE=../cmake/android.toolchain.cmake -DANDROID_TOOLCHAIN_NAME=arm-linux-androideabi-4.8 -DANDROID_NATIVE_API_LEVEL=android-9 ../ -DCMAKE_BUILD_TYPE=Release
cd "$DIR"
cmake --build build_lj_x86 --config Release
mkdir -p plugin_luajit/Plugins/Android/libs/x86/
cp build_lj_x86/libxlua.so plugin_luajit/Plugins/Android/libs/x86/libxlua.so


