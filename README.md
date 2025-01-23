# Sokoban

## About
Sokoban is a game where players move boxes to designated target locations. The player wins when all boxes are correctly placed on the targets. This implementation uses the `starter.s` file in the Ripes software. The game features a single-player or multi-player mode.

---

## Requirements
- **Players**: Minimum 1 player
- **Playing Time**: Approximately 5 minutes
- **Age**: 6+ years

---

## Main Components
1. **Character**
   - Controlled by the player using the D-pad.
   - Represented by a **Yellow LED**.

2. **Box**
   - Needs to be pushed to the target.
   - Represented by a **Red LED**.

3. **Target**
   - Where the boxes must be placed to win.
   - Represented by a **Blue LED**.

4. **Wall**
   - Blocks movement of the character and boxes.
   - Present at the edges of the game field.
   - Represented by a **Grey LED**.

---

## Setup
1. Download and install Ripes software.
2. Load the `starter.s` file in Ripes:
   - Click **File** > **Load Program**, select `starter.s`, and click OK.
3. Configure the processor settings:
   - Select **32-bit** and **Single-cycle processor** and click OK.
4. Configure I/O settings:
   - Add **D-pad** and **LED Matrix** options if not present.
   - Adjust **Height**, **Width**, and **Size** in the LED Matrix panel as desired.
5. Open the Editor and Console tabs.
6. Start the game by clicking the `>>` button.

---

## How to Play
1. Enter the number of players when prompted.
2. Use the D-pad to move the character:
   - **Boxes** can only be moved if adjacent to the character.
   - **Invalid moves** (e.g., moving into walls or misaligned boxes) will display an "Invalid Move!" notification.
3. Multi-player mode:
   - Players take turns.
   - The game displays the cumulative standings and the winner at the end of all rounds.
4. Winning Conditions:
   - Push all boxes onto targets.
   - Lowest number of moves wins. Ties are broken by the earliest round completion.

---

## Ending/Restarting the Game
- **End the game**:
  - Move the character to the top-left of the field.
  - Click the **Left** button on the D-pad.
  - A prompt confirms the game has ended.

- **Restart the game**:
  - Move the character to the top-left of the field.
  - Click the **Top** button on the D-pad.
  - A prompt confirms the game has restarted.

---

## Encountered Problems
If you encounter any issues:
- Ensure the Ripes setup and configuration are correct.
- Review invalid moves and adjust gameplay accordingly.

---

Enjoy playing Sokoban!
