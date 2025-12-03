#!/bin/bash

# Script to generate Xcode framework project with iOS support
# This creates a standard Xcode project that can be opened in Xcode IDE

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Generating Xcode Framework Project with iOS support...${NC}"

# Clean previous build
if [ -d "build-xcode-framework-ios" ]; then
    echo -e "${YELLOW}Cleaning previous build...${NC}"
    rm -rf build-xcode-framework-ios
fi

# Create build directory
mkdir -p build-xcode-framework-ios
cd build-xcode-framework-ios

# Generate Xcode project with iOS framework support
echo -e "${YELLOW}Generating Xcode project with iOS support...${NC}"
cmake -G Xcode \
    -DCMAKE_SYSTEM_NAME=iOS \
    -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
    -DCMAKE_OSX_DEPLOYMENT_TARGET="11.0" \
    -DSIMPLE_WITH_JIEBA=ON \
    -DBUILD_TEST_EXAMPLE=OFF \
    ..

echo -e "${GREEN}Xcode project with iOS support generated successfully!${NC}"
echo -e "${YELLOW}You can now open the project in Xcode:${NC}"
echo -e "  open build-xcode-framework-ios/simple-tokenizer.xcodeproj"
echo -e "${YELLOW}Then build the 'simple' framework target for iOS.${NC}"


echo -e "${GREEN}Building XCFramework using Xcode Archive method...${NC}"

# Clean previous builds
if [ -d "archives" ]; then
    echo -e "${YELLOW}Cleaning previous archives...${NC}"
    rm -rf archives
fi

if [ -d "simple.xcframework" ]; then
    echo -e "${YELLOW}Cleaning previous xcframework...${NC}"
    rm -rf simple.xcframework
fi

# Create archives directory
mkdir -p archives

# Build for iOS devices
echo -e "${YELLOW}Building archive for iOS devices...${NC}"
xcodebuild archive \
  -scheme simple \
  -destination "generic/platform=iOS" \
  -archivePath "archives/ios_devices.xcarchive" \
  -sdk iphoneos \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES

# Build for iOS simulators
echo -e "${YELLOW}Building archive for iOS simulators...${NC}"
xcodebuild archive \
  -scheme simple \
  -destination "generic/platform=iOS Simulator" \
  -archivePath "archives/ios_simulators.xcarchive" \
  -sdk iphonesimulator \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES

# Create XCFramework
echo -e "${YELLOW}Creating XCFramework...${NC}"
xcodebuild -create-xcframework \
  -framework "archives/ios_devices.xcarchive/Products/@rpath/simple.framework" \
  -framework "archives/ios_simulators.xcarchive/Products/@rpath/simple.framework" \
  -output "simple.xcframework"

echo -e "${GREEN}XCFramework created successfully!${NC}"

cd ..
