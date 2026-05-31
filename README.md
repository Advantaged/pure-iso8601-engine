# pure-iso8601-engine

A dynamic, language-agnostic cross-distribution system initialization engine designed by **Tony Advantaged** to enforce true, uniform ISO-8601 (`YYYY-MM-DD`) date and time metrics across Linux environments and the KDE Plasma Desktop without disrupting existing regional formatting or system languages.

## The Problem: Why This Is Necessary

Modern Linux distributions running the GNU C Library (`glibc`) and desktop environments like KDE Plasma do not provide a native, out-of-the-box option for strict ISO-8601 date formatting without forcing unwanted regional or linguistic side effects. 

System administrators and power users demanding international standard metrics face three major systemic roadblocks:

1. **The Regional Packaging Trap:** Attempting to use regional locales like `en_DK` (English/Denmark) or `sv_SE` (Swedish) to force an ISO date template introduces unwanted localization data. `sv_SE` translates system calendars into Swedish (e.g., changing Saturday to `lördag`), while `en_DK` formats long-form dates using non-standard variants.
2. **The Hybrid Matrix Destruction:** Standard localization switchers assume an all-or-nothing approach. If an administrator uses a hybrid configuration—such as an English language desktop interface (`en_US`) paired with German (`de_DE`) numeric, paper, and monetary metrics—naive scripts break this balance by forcing a single language across all categories.
3. **KDE Plasma GUI Constraints:** The KDE Frameworks translation subsystem (`kcm_formats`) cross-references active environment variables against a hardcoded internal lookup array of known countries. Custom locales created outside this database (such as a raw `en_ISO`) are ignored by the GUI, causing Plasma to fall back to standard `en_US` definitions during startup or user session initialization.
4. **The Package Manager `glibc` Wipeout:** Any custom locale compiled manually inside `/usr/share/i18n/locales/` is treated as transient data by package managers (`pacman`, `apt`, `dnf`). The moment a system update touches `glibc` or `glibc-locales`, the upstream package completely overwrites the directory, erasing the custom layout and silently breaking the user's desktop rendering on the next login.

## The Engineering Solution

This engine resolves these structural limitations using an intelligent, adaptive four-stage deployment framework:

* **The Swiss Army Knife Protocol (Dynamic Environment Reflection):** At runtime, the engine sniffs and extracts the user's active configuration matrix entry-by-entry (`LANG`, `LC_CTYPE`, `LC_NUMERIC`, `LC_MONETARY`, etc.). It utilizes `glibc` `copy` directives inside the blueprint to perfectly replicate the user's existing choices. This ensures that month names, currencies, and numbers are untouched, while the strict ISO-8601 directives surgically overwrite *only* the target temporal targets below the copy macro.
* **Strategic Stealth Injection:** The engine runs an automated discovery sequence to find an unutilized English-speaking country container native to the glibc database (such as `en_IE`, `en_GB`, or `en_AU`). It uses this verified container as a host vehicle, bypassing the KDE Plasma GUI lookup constraints completely.
* **Decoupled Architecture Storage:** Your tailored engine formatting blueprints are safely installed into isolated user-space storage (`~/.config/LOLS/`), completely isolated from the package manager's reach.
* **Persistent Package Manager Hooks:** The script automatically analyzes the host operating system to identify the package management architecture. It natively deploys a system transaction hook (`ALPM core hook`, `APT post-invoke configuration`, or `DNF plugin action`). The split-second `glibc` is updated in the background, the hook intercepts the transaction, strips immutable flags, re-injects the blueprint, and re-compiles the binary structure instantly using raw `localedef` compilation.

---

## Deployment & Installation

Clone the repository and run the self-contained installation manifest:

```bash
git clone https://github.com/Advantaged/pure-iso8601-engine.git
cd pure-iso8601-engine
chmod +x install-iso-locale.sh
sudo ./install-iso-locale.sh
```

### Runtime Integration Vectors

Upon completion, the installer provides three compliance execution options:
1. **Live Hot-Reload:** Completely unsets active parent shell environment boundaries, sources the central system profile subsystems (`/etc/profile.d/locale.sh`), drops micro-service reload rules for running daemons, and verifies integrity using a standalone Perl parsing sequence.
2. **Session Termination:** Dynamically queries `loginctl` to locate all active graphical attachment matrices belonging to the user, terminates the session trees cleanly to save active states, and issues a hard-restart command to the display manager/session layer (`plasmalogin`).
3. **Staged Configuration:** Writes the baseline profiles smoothly into `/etc/locale.conf` and the local user spaces to apply cleanly on the next physical hardware initialization loop.

## Compliance Standards
* **Architect & Author:** Tony Advantaged
* **Date Metrics:** ISO 8601 (`YYYY-MM-DD HH:MM:SS`)
* **Locale Layout Logic:** Dynamic Environment Mapping (Full Hybrid Matrix Preservation)
* **Compilation Standard:** Strict `glibc` `localedef` Compliant (`%` Comment Bound)
* **Documentation Architecture:** ISO 9001 Compliant Systems Specification

.  
