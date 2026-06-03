# Offscene Mechanic Work Order
## How to get your clean .EXE (no CMD, no warnings)

---

### Option A — Build a real .exe (recommended)

This creates a **self-contained Windows installer** — no Java required on the target PC.

**Steps:**
1. Make sure you have the **Java 17+ JDK** installed  
   Download free from: https://adoptium.net  
   (Must be the full JDK, not just JRE)

2. Right-click `BuildEXE.ps1` → **Run with PowerShell**  
   (Or: open PowerShell, `cd` to this folder, run `.\BuildEXE.ps1`)

3. After ~60 seconds, a `dist\` folder appears with `OffsceneMechanicSetup.exe`

4. Run the installer — it will:
   - Install the app to Program Files
   - Create a Desktop shortcut
   - Open directly as a GUI, **zero CMD windows, zero security warnings**

---

### Option B — Quick test (requires Java installed)

Double-click `Launch.bat` — opens the app using `javaw` (no CMD window).  
This is for testing only, not for distribution.

---

### Why is there no .exe in this ZIP?

A proper Windows `.exe` can only be built **on a Windows machine** using `jpackage`  
(a tool built into the Java JDK). The `BuildEXE.ps1` script does exactly that  
automatically. Once built, the resulting `.exe` bundles its own Java runtime —  
so end users don't need Java installed at all.
