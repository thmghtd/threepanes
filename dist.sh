set -o errexit
test -d build && rm -r build
xcodebuild -configuration Release
osascript -e 'if application "Three Panes" is running then tell application "Three Panes" to quit'
rm -rf ~/Desktop/Three\ Panes.app
mv build/Release/Three\ Panes.app ~/Desktop
