# Ultimate Tic-Tac-Toe: Setup & Build Instructions

This project is a high-tech version of Ultimate Tic-Tac-Toe built with Flutter, featuring P2P networking and custom themes.

## 1. Prerequisites
- **Flutter SDK**: Installed on your computer ([flutter.dev](https://docs.flutter.dev/get-started/install)).
- **Mobile Devices**: Two Android/iOS devices for P2P testing.

## 2. Local Setup
Since this is a custom scaffold, you need to generate the platform folders (Android/iOS) on your machine:

1.  Open your terminal.
2.  Navigate to the project folder:
    ```bash
    cd ultimate_ttt
    ```
3.  Run the create command to generate platform boilerplate:
    ```bash
    flutter create .
    ```
4.  Get the dependencies:
    ```bash
    flutter pub get
    ```

## 3. Important: Networking Permissions
To use the **PIN Room System**, the app needs Bluetooth and Location permissions (standard for P2P discovery).

### For Android:
The `nearby_connections` library will handle most permissions, but ensure your `android/app/src/main/AndroidManifest.xml` includes these (usually added automatically by the library):
- `BLUETOOTH`, `BLUETOOTH_ADMIN`, `ACCESS_FINE_LOCATION`, `NEARBY_WIFI_DEVICES`.

### For iOS:
You must add keys to your `ios/Runner/Info.plist`:
- `NSBluetoothAlwaysUsageDescription`: "Needed for P2P multiplayer."
- `NSLocalNetworkUsageDescription`: "Needed to find rooms on Wi-Fi."
- `NSBonjourServices`: Add `_nearby-devices._tcp` and `_nearby-devices._udp`.

## 4. How to Play
1.  **Launch** the app on both devices.
2.  **Player 1 (Host)**: Enter names, pick a theme, tap "CREATE ROOM," and set a 4-digit PIN.
3.  **Player 2 (Joiner)**: Enter names, tap "JOIN ROOM," and enter the SAME PIN.
4.  **Sync**: Once connected, Player 2's theme and names will automatically sync to match Player 1's settings.

## 5. Game Rules Recap
- **Sending**: Your move's position inside the small grid determines which large square the opponent plays in next.
- **Won Squares**: A faint overlay shows if a square is won, but you can still play there!
- **Free Move**: If you're sent to a big square that is 100% full, you can play anywhere on the board.
