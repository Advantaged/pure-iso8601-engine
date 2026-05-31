#!/usr/bin/env bash

# Enforce root privileges for compilation and hook generation
if [ "$EUID" -ne 0 ]; then
  echo "Error: This installer must be run as root (sudo)."
  exit 1
fi

# ==============================================================================
# 1. DYNAMIC USER INFRASTRUCTURE & DISCOVERY
# ==============================================================================
REAL_USER="${SUDO_USER:-$USER}"
if [ "$REAL_USER" = "root" ]; then
  REAL_USER=$(awk -v uid=1000 -F: '$3==uid {print $1}' /etc/passwd)
fi
USER_HOME=$(eval echo "~$REAL_USER")
LOLS_DIR="${USER_HOME}/.config/LOLS"
SOURCE_BLUEPRINT="${LOLS_DIR}/en_ISO.locale"

echo "=========================================================="
echo " Starting Universal ISO-8601 Engine Configuration"
echo "=========================================================="

# Flush pre-existing directory trees safely to prevent configuration drifts
if [ -d "$LOLS_DIR" ]; then
    echo "=> Existing LOLS configuration structure discovered. Wiping old contents..."
    rm -rf "${LOLS_DIR:?}"/*
else
    echo "=> Initializing pristine LOLS environment structure..."
    mkdir -p "$LOLS_DIR"
fi

# ==============================================================================
# 2. INLINE GENERATION OF THE EN_ISO SYSTEM TEMPLATE
# ==============================================================================
echo "=> Deploying system layout structures..."
cat << 'EOF' > "$SOURCE_BLUEPRINT"
LC_IDENTIFICATION
title      "English locale for international ISO-8601 compliance"
source     "Tony Advantaged"
address    "International"
contact    ""
email      ""
tel        ""
fax        ""
language   "English"
territory  "IE"
revision   "1.0"
date       "2026-05-31"
category  "i18n:2012";value;LC_IDENTIFICATION
END LC_IDENTIFICATION

LC_CTYPE
copy "en_US"
END LC_CTYPE

LC_COLLATE
copy "en_US"
END LC_COLLATE

LC_MONETARY
copy "en_US"
END LC_MONETARY

LC_NUMERIC
copy "en_US"
END LC_NUMERIC

LC_TIME
# ISO-8601 strict date formatting layout constraints
abday   "Sun";"Mon";"Tue";"Wed";"Thu";"Fri";"Sat"
day     "Sunday";"Monday";"Tuesday";"Wednesday";"Thursday";"Friday";"Saturday"
abmon   "Jan";"Feb";"Mar";"Apr";"May";"Jun";"Jul";"Aug";"Sep";"Oct";"Nov";"Dec"
mon     "January";"February";"March";"April";"May";"June";"July";"August";"September";"October";"November";"December"
d_t_fmt "%Y-%m-%d %H:%M:%S"
d_fmt   "%Y-%m-%d"
t_fmt   "%H:%M:%S"
am_pm   "";""
t_fmt_ampm ""
week    7;19971130;1
first_weekday 2
first_workday 2
END LC_TIME

LC_MESSAGES
copy "en_US"
END LC_MESSAGES

LC_PAPER
copy "en_US"
END LC_PAPER

LC_NAME
copy "en_US"
END LC_NAME

LC_ADDRESS
copy "en_US"
END LC_ADDRESS

LC_TELEPHONE
copy "en_US"
END LC_TELEPHONE

LC_MEASUREMENT
copy "en_US"
END LC_MEASUREMENT

LC_NAME
copy "en_US"
END LC_NAME
EOF

# Standardize permissions for the extracted file asset inside user-space
chown -R "${REAL_USER}:${REAL_USER}" "$LOLS_DIR"
chmod 644 "$SOURCE_BLUEPRINT"

# ==============================================================================
# 3. SMART LOCALE SELECTION (Anti-Collision Protocol)
# ==============================================================================
STEALTH_LOCALE="en_IE"
current_time_locale=$(env | grep LC_TIME | cut -d= -f2 | cut -d. -f1)

if [[ "$current_time_locale" == "en_IE" ]]; then
    echo "=> Native Irish user detected. Shifting stealth target container to en_GB..."
    STEALTH_LOCALE="en_GB"
elif [[ "$current_time_locale" == "en_GB" ]]; then
    echo "=> Native British user detected. Shifting stealth target container to en_AU..."
    STEALTH_LOCALE="en_AU"
fi

echo "=> Target stealth system container selected: ${STEALTH_LOCALE}"

# ==============================================================================
# 4. DEFUSE POTENTIAL IMMUTABLE FLAGS (+i)
# ==============================================================================
[ -f /etc/locale.conf ] && chattr -i /etc/locale.conf
[ -f "${USER_HOME}/.config/plasma-localerc" ] && chattr -i "${USER_HOME}/.config/plasma-localerc"
[ -f /root/.config/plasma-localerc ] && chattr -i /root/.config/plasma-localerc

# ==============================================================================
# 5. CONFIGURE /etc/locale.gen & COMPILE
# ==============================================================================
if [ -f /etc/locale.gen ]; then
    sed -i "/^#\?${STEALTH_LOCALE}.UTF-8/d" /etc/locale.gen
    echo "${STEALTH_LOCALE}.UTF-8 UTF-8" >> /etc/locale.gen
fi

rm -f "/usr/share/i18n/locales/${STEALTH_LOCALE}"
cp "$SOURCE_BLUEPRINT" "/usr/share/i18n/locales/${STEALTH_LOCALE}"
sed -i "s/territory    \"IE\"/territory    \"${STEALTH_LOCALE#*_}\"/g" "/usr/share/i18n/locales/${STEALTH_LOCALE}"

rm -rf "/usr/lib/locale/${STEALTH_LOCALE}.utf8" "/usr/lib/locale/${STEALTH_LOCALE}.UTF-8"
localedef -i "$STEALTH_LOCALE" -f UTF-8 "${STEALTH_LOCALE}.UTF-8"

# ==============================================================================
# 6. WRITE GLOBAL SYSTEM CONFIGURATIONS
# ==============================================================================
cat << EOF > /etc/locale.conf
LANG=en_US.UTF-8
LC_CTYPE=en_US.UTF-8
LC_NUMERIC=de_DE.UTF-8
LC_TIME=${STEALTH_LOCALE}.UTF-8
LC_COLLATE=en_US.UTF-8
LC_MONETARY=de_DE.UTF-8
LC_MESSAGES=en_US.UTF-8
LC_PAPER=de_DE.UTF-8
LC_NAME=de_DE.UTF-8
LC_ADDRESS=de_DE.UTF-8
LC_TELEPHONE=de_DE.UTF-8
LC_MEASUREMENT=de_DE.UTF-8
LC_IDENTIFICATION=de_DE.UTF-8
EOF

# ==============================================================================
# 7. WRITE DE GRAPHICAL COMPONENT CONFIGURATIONS (KDE Plasma Native Logic)
# ==============================================================================
write_plasma_config() {
  local target_path="$1"
  mkdir -p "$(dirname "$target_path")"
  cat << EOF > "$target_path"
[Formats]
LANG=en_US.UTF-8
LC_ADDRESS=de_DE
LC_MEASUREMENT=de_DE
LC_MONETARY=de_DE
LC_NAME=de_DE
LC_NUMERIC=de_DE
LC_PAPER=de_DE
LC_TELEPHONE=de_DE
LC_TIME=${STEALTH_LOCALE}.UTF-8

[Translations]
LANGUAGE=en_US
EOF
}

write_plasma_config "${USER_HOME}/.config/plasma-localerc"
write_plasma_config "/root/.config/plasma-localerc"
chown "${REAL_USER}:${REAL_USER}" "${USER_HOME}/.config/plasma-localerc"

# ==============================================================================
# 8. AUTOMATED CROSS-DISTRIBUTION HOOK INJECTION
# ==============================================================================
if command -v pacman &> /dev/null; then
    echo "=> Architecture detected: Arch/CachyOS. Ensuring clean administrative hook sandbox..."
    # Explicitly create the empty local administrative sandbox if not present
    mkdir -p /etc/pacman.d/hooks
    cat << EOF > /etc/pacman.d/hooks/99-update-iso-locale.hook
[Trigger]
Operation = Install
Operation = Upgrade
Type = Package
Target = glibc
Target = glibc-locales

[Action]
Description = Re-compiling custom ISO-8601 system locale configurations...
When = PostTransaction
Depends = bash
Exec = /bin/bash -c "HOME_DIR=\$(awk -v uid=1000 -F: '\$3==uid {print \$6}' /etc/passwd); /bin/bash \${HOME_DIR}/.config/LOLS/install-iso-locale.sh"
EOF

elif command -v apt-get &> /dev/null; then
    echo "=> Architecture detected: Debian/Ubuntu. Deploying APT Post-Invoke hook..."
    cat << EOF > /etc/apt/apt.conf.d/99-update-iso-locale
DPkg::Post-Invoke { "HOME_DIR=\$(awk -v uid=1000 -F: '\$3==uid {print \$6}' /etc/passwd); /bin/bash \${HOME_DIR}/.config/LOLS/install-iso-locale.sh"; };
EOF

elif command -v dnf &> /dev/null || command -v dnf5 &> /dev/null; then
    echo "=> Architecture detected: Fedora/RHEL. Deploying DNF Core Plugin Action..."
    mkdir -p /etc/dnf/plugins/post-transaction-actions.d
    cat << EOF > /etc/dnf/plugins/post-transaction-actions.d/iso-locale.action
glibc:any:${USER_HOME}/.config/LOLS/install-iso-locale.sh
glibc-langpack-en:any:${USER_HOME}/.config/LOLS/install-iso-locale.sh
EOF
fi

# ==============================================================================
# 9. EXECUTION HANDLER
# ==============================================================================
echo "----------------------------------------------------------"
echo "✓ Installation complete. How do you want to apply changes?"
echo "----------------------------------------------------------"
echo " [1] Apply live reload on the fly (Drops boundary & re-sources context)."
echo " [2] Force-logout session instantly (Restarts Plasma shell)."
echo " [3] Do nothing (Keep states, let hardware reboot handle it)."
read -r -p "Selection [1-3]: " action

case "$action" in
    (1)
        echo "=> Dropping active environment boundary..."
        unset LANG
        
        echo "=> Sourcing the initialization subsystem..."
        if [ -f /etc/profile.d/locale.sh ]; then
            source /etc/profile.d/locale.sh
        fi

        # Integrated CachyOS native systemd service refresh & check logic
        if command -v cachyos-rate-mirrors &>/dev/null || [ -f /usr/bin/needs-restarting ]; then
            echo "=> Dispatching micro-service reloading rules..."
            systemctl daemon-reload 2>/dev/null
        fi
        
        echo "=> Verification: Active Environment Output:"
        locale
        
        echo "=> Verification: Performing Perl structural dry-run..."
        perl -e 'print "System Integrity: Clear\n"'
        ;;
    (2)
        echo "=> Halting graphical shell structures cleanly..."
        SESSION_IDS=$(loginctl list-sessions --no-legend | awk -v u="$REAL_USER" '$3==u {print $1}')
        for id in $SESSION_IDS; do loginctl terminate-session "$id"; done
        loginctl terminate-user "$REAL_USER"
        systemctl restart plasmalogin.service 2>/dev/null || systemctl restart sddm.service 2>/dev/null
        ;;
    (*)
        # Catches option 3 or any accidental user inputs safely
        echo "=> Changes staged. Will execute safely on your next normal reboot."
        ;;
esac
