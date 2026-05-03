# Ultimate Tic-Tac-Toe: Mobile Mockups

To ensure the game feels modern and polished on your phone, I've designed three core screens. These emphasize visual depth, interactive feedback, and high contrast.

## 1. The Home Screen (Setup & Themes)
This screen is the gateway. It uses a deep gradient background and glassmorphism for the input cards.

*   **Background**: A dark-to-vibrant gradient (e.g., Deep Space Purple to Midnight Blue).
*   **Header**: "ULTIMATE TTT" in a bold, neon-style font with a slight outer glow.
*   **Player Cards**: Two rounded-rectangle cards with frosted glass effect. 
    *   Player 1 (X) Input: Accented with Neon Purple.
    *   Player 2 (O) Input: Accented with Neon Cyan.
*   **Theme Carousel**: A horizontal scrolling row of circular "Planet" previews representing themes (Barbie, Summer, Galaxy, etc.). Tapping one updates the app's accent colors instantly.
*   **Action Buttons**: Large, pill-shaped buttons at the bottom: "CREATE ROOM" (Solid Purple) and "JOIN ROOM" (Outline Cyan).

---

## 2. The Battleground (Active Gameplay)
This is where the game happens. The UI is designed to focus your eyes on the move that matters.

*   **Top Bar**: Minimalist. 
    *   Left: Exit (X) icon. 
    *   Center: "CONNECTED" status with a small pulsing green dot.
    *   Right: Restart icon.
*   **The Grid**: 
    *   **Inactive Squares**: Dimmed to 20% opacity. The underlying 3x3 grid lines are barely visible, making the square look like it's in "power save" mode.
    *   **Active Square**: Bright, 100% opacity with a **thick, pulsing neon border** (the "Engaged" state).
    *   **Won Squares**: A faint, giant "X" or "O" (15% opacity) appears behind the mini-grid.
    *   **Tied Squares**: A faint grey "T".
*   **Bottom Turn Indicator**: A wide banner showing "YOUR TURN" in large, high-contrast letters with a glowing circle indicating the active player.

---

## 3. The "Unanimous Decision" Overlay
When a tie or restart request occurs, the game enters a "Paused" visual state.

*   **Visual Treatment**: The entire board behind the dialog blurs significantly (Gaussian blur).
*   **The Dialog**: A floating card with a sharp, modern header: "MINI-GRID DRAW!"
*   **Contextual Icons**: A small icon showing the specific mini-grid that tied.
*   **Decision Buttons**: 
    *   "CONTINUE PLAYING" (Grey/Outline): For those who want to fight to the end.
    *   "END IN DRAW" (Solid Red/Accent): To shake hands and reset.
*   **Real-time Feedback**: Small text below the buttons says: *"Waiting for [Opponent Name]..."* once you've made your choice.

---

### Key Visual Elements:
- **Animations**: Smooth transitions when the active grid shifts.
- **Haptics**: Subtle vibration on each move and a stronger "thud" when a mini-grid is won.
- **Sound (Optional)**: Modern UI blips and a distinct "Success" chime for a win.
