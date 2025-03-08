#!/bin/bash

# Usage: deploy_jar_app.sh

JAR_PATH="$1"
APP_NAME="$2"
APP_VERSION="$3"

if [ -z "$JAR_PATH" ] || [ -z "$APP_NAME" ] || [ -z "$APP_VERSION" ]; then
    echo "Usage: deploy_java_app.sh <jar_path> <app_name> <app_version>"
    exit 1
fi

# Define directories
APPS_DIR="$HOME/.local/Apps"
APPS_DIR_REL='$HOME/.local/Apps'
BIN_DIR="$HOME/.local/bin"

if [[ "$APP_VERSION" == "SNAPSHOT" ]]; then
    # Use wildcard pattern for SNAPSHOT JAR file
    JAR_DIR=$(dirname "$JAR_PATH")
    JAR_WILDCARD="*-SNAPSHOT-*.jar"

    # Create the executable script in the bin directory
    EXECUTABLE="$BIN_DIR/${APP_NAME}-SNAPSHOT"
    echo "#!/bin/bash" > "$EXECUTABLE"
    echo "JAR_DIR=\"$JAR_DIR\"" >> "$EXECUTABLE"
    echo "JAR_WILDCARD=\"$JAR_WILDCARD\"" >> "$EXECUTABLE"
    echo "FULL_JAR_PATH=\$(find \"\$JAR_DIR\" -maxdepth 1 -name \"\$JAR_WILDCARD\" -type f | head -n 1)" >> "$EXECUTABLE"
    echo "if [ -z \"\$FULL_JAR_PATH\" ]; then" >> "$EXECUTABLE"
    echo "  echo \"Error: No JAR file matching '\$JAR_WILDCARD' found in '\$JAR_DIR'.\"" >> "$EXECUTABLE"
    echo "  exit 1" >> "$EXECUTABLE"
    echo "fi" >> "$EXECUTABLE"
    echo "java -jar \"\$FULL_JAR_PATH\" \"\$@\"" >> "$EXECUTABLE"
    chmod +x "$EXECUTABLE"
    echo "SNAPSHOT version deployed. You can run it using: $EXECUTABLE"
else
    # Handle other versions by creating a target directory
    TARGET_DIR="$APPS_DIR/$APP_NAME/$APP_VERSION"
    TARGET_DIR_REL="$APPS_DIR_REL/$APP_NAME/$APP_VERSION"
    mkdir -p "$TARGET_DIR"

    # Copy the application to the target directory
    cp "$JAR_PATH" "$TARGET_DIR"

    # Create an executable script in the bin directory
    EXECUTABLE="$BIN_DIR/${APP_NAME}-${APP_VERSION}"
    echo "#!/bin/bash" > "$EXECUTABLE"
    echo "java -jar \"$TARGET_DIR_REL/$(basename "$JAR_PATH")\" \"\$@\"" >> "$EXECUTABLE"
    chmod +x "$EXECUTABLE"
    echo "Application deployed. You can run it using: $EXECUTABLE"
fi

