# pure-iso8601-engine

A cross-distribution system automation engine designed to enforce true, uniform ISO-8601 (`YYYY-MM-DD`) date and time metrics across Linux environments and the KDE Plasma Desktop without causing system language or locale collisions.

## The Problem: Why This Is Necessary

Modern Linux distributions running the GNU C Library (`glibc`) and desktop environments like KDE Plasma do not provide a native, out-of-the-box option for strict ISO-8601 date formatting without forcing unwanted regional or linguistic side effects. 

System administrators and users demanding international standard metrics face three major systemic roadblocks:

1. **The Regional Packaging Trap:** Attempting to use regional locales like `en_DK` (English/Denmark) or `sv_SE` (Swedish) to get an ISO date format introduces unwanted localization payload. `sv_SE` translates system calendar text into Swedish (e.g., changing Saturday to `lördag`), while `en_DK` formats long-form dates using non-standard variants.
2. **KDE Plasma GUI Constraints:** The KDE Frameworks translation subsystem (`kcm_formats`) cross-references active environment variables against a hardcoded internal lookup array of known countries. Custom locales created outside this database (such as a raw `en_ISO`) are ignored by the GUI, causing Plasma to fall back to standard `en_US` definitions during startup or user session initialization.
3. **The Package Manager `glibc` Wipeout:** Any custom locale compiled manually inside `/usr/share/i18n/locales/` is treated as transient data by package managers (`pacman`, `apt`, `dnf`). The moment a system update touches `glibc` or `glibc-locales`, the upstream package completely overwrites the directory, erasing the custom layout and silently breaking the user's desktop rendering on the next login.

## The Engineering Solution

This engine resolves these structural limitations using a three-stage automated deployment framework:

* **Strategic Stealth Injection:** The engine runs an automated discovery sequence to find an unutilized English-speaking country container native to the glibc database (such as `en_IE`, `en_GB`, or `en_AU`). It uses this verified container as a host vehicle, bypassing the KDE Plasma GUI lookup constraints completely.
* **Decoupled Architecture Storage:** Your tailored `en_ISO` formatting rules are safely installed into user-space storage (`~/.config/LOLS/`), completely isolated from the package manager's reach.
* **Persistent Package Manager Hooks:** The script automatically analyzes the host operating system to identify the package management architecture. It natively deploys a system transaction hook (`ALPM core hook`, `APT post-invoke configuration`, or `DNF plugin action`). The split-second `glibc` is updated in the background, the hook intercepts the transaction, strips immutable flags, re-injects the blueprint, and re-compiles the binary structure instantly using raw `localedef` compilation.

---

## Deployment & Installation

Clone the repository and run the self-contained installation manifest:

```bash
git clone [https://github.com/yourusername/pure-iso8601-engine.git](https://github.com/yourusername/pure-iso8601-engine.git](https://github.com/Advantaged/pure-iso8601-engine.git)
cd pure-iso8601-engine
chmod +x install-iso-locale.sh
sudo ./install-iso-locale.sh
```
.
