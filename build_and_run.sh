#!/bin/bash

# Build and run script for DatecsFPrint macOS app

echo "Building DatecsFPrint..."

# Build the project
xcodebuild -project DatecsFPrint.xcodeproj -scheme DatecsFPrint -configuration Debug -derivedDataPath build

if [ $? -eq 0 ]; then
    echo "Build successful!"

    # Find the built app
    APP_PATH=$(find build -name "DatecsFPrint.app" -type d | head -1)

    if [ -n "$APP_PATH" ]; then
        echo "Found app at: $APP_PATH"

        # Run the app
        if [ "$1" == "cli" ]; then
            echo "Running in CLI mode..."
            shift
            "$APP_PATH/Contents/MacOS/DatecsFPrint" --cli "$@"
        else
            echo "Running GUI app..."
            open "$APP_PATH"
        fi
    else
        echo "Could not find built app"
        exit 1
    fi
else
    echo "Build failed!"
    exit 1
fi