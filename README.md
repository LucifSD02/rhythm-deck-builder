## **Rhythm Roguelite Deckbuilder: Game Design Document (GDD)**


### **1\. Core Gameplay Loop & Architecture**

* **Genre**: 2D Rhythm Roguelite Deckbuilder (Single-player, PC-only, indie release).  
* **Time Architecture**: **Hybrid Turn-Based**. Battles are split into two distinct phases to eliminate player panic and allow tactical thinking.  
* **Phase 1: The Planning Phase**:  
  * The background environment track loops continuously.  
  * The player draws a hand of cards and assesses enemy intents (e.g., *"Enemy attacking for 12 damage on Beat 4"*).  
  * The player spends energy or bar space (TBD) to queue cards into a visual execution timeline.  
* **Phase 2: The Countdown**:  
  * Upon ending the turn, a rhythm-synced countdown (e.g., *1, 2, 3, Go\!*) triggers.  
  * This aligns the player’s focus directly with the active Beats Per Minute (BPM) before inputs begin.  
* **Phase 3: The Execution Phase**:  
  * The queued notes glide across an execution timeline.  
  * The player uses a keyboard-only input setup to hit targets in real-time.  
* **Phase 4: Resolution**:  
  * The rhythm sequence ends. Performance metrics are calculated.  
  * Damage, shields, and global status modifiers are processed based on hit accuracy.  
  * The enemy executes their telegraphed turn, and the cycle resets.

### **2\. Combat & Card Phrasing System**

* **Health (HP)**: A permanent pool carrying over between combat encounters. Reaching zero ends the run.  
* **Shields (Block)**: Generated via defensive cards during execution. Absorbs damage at the spot in the bar where the card is located, and **completely decays (vanishes)** at the start of the player's next turn.  
* **Armor**: Permanent damage mitigation that reduces all incoming flat damage values and does not decay between turns.  
* **Musical Phrasing Cards**: Cards occupy fractional parts of a musical bar rather than fixed time segments.  
  * **Short Phrases**: 1-beat or 2-beat cards. Cost less energy, offer highly specific utility (e.g., filling a sudden gap in defense).  
  * **Long Phrases**: 3-beat or 4-beat cards. Cost more energy, feature complex note layouts, and unlock wide-reaching utility.  
  * **Bar Composition & Rests**: A turn is budgeted by musical measures (e.g., 2 bars / 8 beats in 4/4 time). If a bar is left incomplete, empty slots automatically convert to **Rest Notes** (silence, no inputs required).  
  * **Combo System**: Playing a "Starter" phrase (e.g., 3 beats) followed by a matching "Finisher" phrase (e.g., 1 beat) completes a full bar and grants an empowered synergy effect. Finishers would most likely use the spacebar spacebar somewhere in the phrase


### **3\. Keyboard Input & Instrument Scaling**

The game uses a **Keyboard-Only** setup during the execution phase. The selected instrument class natively dictates the physical finger posture and difficulty tier:

* **Bass & Drums (4-Key Layout)**:  
  * *Layout*: D F J K \+ Space  
  * *Difficulty*: Beginner. Focuses heavily on steady rhythms, simultaneous notes (Drums), and hold notes (Bass).  
* **Guitar (6-Key Layout)**:  
  * *Layout*: S D F J K L \+ Space  
  * *Difficulty*: Intermediate. Introduces wider physical hand coordination and chord structures.  
* **Piano & Melodic Percussion (8-Key Layout)**:  
  * *Layout*: A S D F H J K L \+ Space  
  * *Difficulty*: Advanced. Maps to a full 7-note musical scale plus its octave, requiring fast scale runs.  
* **The Universal Special Key (Spacebar)**: A dedicated bonus key shared by all instruments. It is reserved for special companion-injected deck mechanics and advanced combo modifiers.   
* **Scoring/Accuracy Pipeline**:  
  * *Good Hit*: The operational standard, awarding 100% of the card's baseline values.  
  * *Perfect Hit*: Acts as a critical multiplier (e.g., 150% value) and triggers passive companion rewards.

### **4\. Run Structure & Long-Term Meta Progression**

* **Party Framework (The Backing Band)**: The player controls **one active musician** on stage. Throughout a run, the player recruits passive "Companions" to fill **4 distinct loadout slots**:  
  1. *Slot 1: Notes Modifier*: Alters note behaviors (e.g., wider timing windows, turning standard taps into shield-generating hold notes).  
  2. *Slot 2: Synergy Modifier*: Injects unique, specialized character class cards directly into your deck pool.  
  3. *Slot 3: Passive Modifier*: Awards passive combat bonuses for performing well (e.g., every 3 consecutive "Perfects" stuns an enemy).  
  4. *Slot 4: Flex Slot*: A wild-card slot that can accept any companion type to let players lean heavily into specific build strategies.  
* **Anatomy of a Run**:  
  * A run consists of **3 distinct environments** styled as concert tour venues. Each environment introduces scaling baseline track BPMs (e.g., 100 BPM up to 150 BPM).  
  * Branching nodes include standard Gigs (fights), Encores (elite fights with rare rewards), and Backstage areas (shops/healing spaces).  
  * *Currencies*: **Fans/Gold** (in-run economy spent at shops; resets on death) and **Inspiration/Vinyl** (meta-currency saved upon death).  
* **Meta Progression Unlocks**:  
  * Defeating bosses and hitting specific criteria unlocks new characters and unique instrument variants.  
  * *Alternative Instruments*: Swapping a character's starting instrument fully exchanges their core starter deck (e.g., trading an Acoustic Guitar for an Electric Guitar).  
  * *The Volume Knob (Difficulties)*: Higher difficulty tiers tighten accuracy windows or introduce unexpected BPM acceleration mid-turn.

