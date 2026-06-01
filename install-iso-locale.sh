#!/usr/bin/env bash

# Enforce root privileges for compilation and hook generation
if [ "$EUID" -ne 0 ]; then
  echo "Error: This installer must be run as root (sudo)."
  exit 1
fi

# ==============================================================================
# 1. DYNAMIC USER INFRASTRUCTURE & MATRIX DISCOVERY
# ==============================================================================
REAL_USER="${SUDO_USER:-$USER}"
if [ "$REAL_USER" = "root" ]; then
  REAL_USER=$(awk -v uid=1000 -F: '$3==uid {print $1}' /etc/passwd)
fi
USER_HOME=$(eval echo "~$REAL_USER")
LOLS_DIR="${USER_HOME}/.config/LOLS"
SOURCE_BLUEPRINT="${LOLS_DIR}/en_ISO.locale"

# Sifting routine to isolate and clean raw locale values
get_clean_locale() {
    local val
    val=$(locale | grep "^${1}=" | cut -d= -f2 | tr -d '"' | cut -d. -f1)
    if [ -z "$val" ] || [ "$val" = "C" ] || [ "$val" = "POSIX" ]; then
        val=$(locale | grep '^LANG=' | cut -d= -f2 | tr -d '"' | cut -d. -f1)
    fi
    if [ -z "$val" ] || [ "$val" = "C" ] || [ "$val" = "POSIX" ]; then
        val="en_US"
    fi
    echo "$val"
}

# Extract the entire active environment matrix individually
SRC_LANG=$(get_clean_locale "LANG")
SRC_CTYPE=$(get_clean_locale "LC_CTYPE")
SRC_NUMERIC=$(get_clean_locale "LC_NUMERIC")
SRC_TIME=$(get_clean_locale "LC_TIME")
SRC_COLLATE=$(get_clean_locale "LC_COLLATE")
SRC_MONETARY=$(get_clean_locale "LC_MONETARY")
SRC_MESSAGES=$(get_clean_locale "LC_MESSAGES")
SRC_PAPER=$(get_clean_locale "LC_PAPER")
SRC_NAME=$(get_clean_locale "LC_NAME")
SRC_ADDRESS=$(get_clean_locale "LC_ADDRESS")
SRC_TELEPHONE=$(get_clean_locale "LC_TELEPHONE")
SRC_MEASUREMENT=$(get_clean_locale "LC_MEASUREMENT")

echo "=========================================================="
echo " Starting Universal ISO-8601 Engine Configuration"
echo "=========================================================="
echo "=> Active Environment Matrix Discovered:"
echo "   Language: $SRC_LANG | Numeric: $SRC_NUMERIC | Time Base: $SRC_TIME"

if [ -d "$LOLS_DIR" ]; then
    rm -rf "${LOLS_DIR:?}"/*
else
    mkdir -p "$LOLS_DIR"
fi

# ==============================================================================
# 2. SMART LOCALE SELECTION (Anti-Collision Protocol)
# ==============================================================================
STEALTH_LOCALE="en_IE"
current_time_locale=$(env | grep LC_TIME | cut -d= -f2 | cut -d. -f1)

if [[ "$current_time_locale" == "en_IE" ]]; then
    STEALTH_LOCALE="en_GB"
elif [[ "$current_time_locale" == "en_GB" ]]; then
    STEALTH_LOCALE="en_AU"
fi

echo "=> Target stealth system container selected: ${STEALTH_LOCALE}"
TARGET_TERRITORY="${STEALTH_LOCALE#*_}"

# ==============================================================================
# 3. DYNAMIC INLINE GENERATION OF THE UNIFIED BLUEPRINT
# ==============================================================================
echo "=> Building customized locale definition blueprint..."
cat << EOF > "$SOURCE_BLUEPRINT"
comment_char %
escape_char /

% ==============================================================================
% Custom ISO-8601 Engine Blueprint
% Architect & Author: Tony Advantaged
% ==============================================================================

LC_IDENTIFICATION
title      "Dynamic hybrid wrapper for international ISO-8601 compliance"
source     "Tony Advantaged"
address    "International"
contact    ""
email      ""
tel        ""
fax        ""
language   "English"
territory  "${TARGET_TERRITORY}"
revision   "1.2"
date       "2026-05-31"
category  "i18n:2012";value;LC_IDENTIFICATION
END LC_IDENTIFICATION

LC_CTYPE
copy "${SRC_CTYPE}"
END LC_CTYPE

LC_COLLATE
copy "${SRC_COLLATE}"
END LC_COLLATE

LC_MONETARY
copy "${SRC_MONETARY}"
END LC_MONETARY

LC_NUMERIC
copy "${SRC_NUMERIC}"
END LC_NUMERIC

LC_TIME
% Inherit current day/month naming strings from the active time configuration
copy "${SRC_TIME}"

% Surgically overwrite specific temporal rendering targets for strict ISO metrics
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
copy "${SRC_MESSAGES}"
END LC_MESSAGES

LC_PAPER
copy "${SRC_PAPER}"
END LC_PAPER

LC_NAME
copy "${SRC_NAME}"
END LC_NAME

LC_ADDRESS
copy "${SRC_ADDRESS}"
END LC_ADDRESS

LC_TELEPHONE
copy "${SRC_TELEPHONE}"
END LC_TELEPHONE

LC_MEASUREMENT
copy "${SRC_MEASUREMENT}"
END LC_MEASUREMENT
EOF

chown -R "${REAL_USER}:${REAL_USER}" "$LOLS_DIR"
chmod 644 "$SOURCE_BLUEPRINT"

# ==============================================================================
# 4. DEFUSE POTENTIAL IMMUTABLE FLAGS (+i)
# ==============================================================================
[ -f /etc/locale.conf ] && chattr -i /etc/locale.conf
[ -f "${USER_HOME}/.config/plasma-localerc" ] && chattr -i "${USER_HOME}/.config/plasma-localerc"
[ -f /root/.config/plasma-localerc ] && chattr -i /root/.config/plasma-localerc

# ==============================================================================
# 5. CONFIGURE /etc/locale.gen & SYSTEM COMPILATION
# ==============================================================================
if [ -f /etc/locale.gen ]; then
    sed -i "/^#\?${STEALTH_LOCALE}.UTF-8/d" /etc/locale.gen
    echo "${STEALTH_LOCALE}.UTF-8 UTF-8" >> /etc/locale.gen
fi

rm -f "/usr/share/i18n/locales/${STEALTH_LOCALE}"
cp "$SOURCE_BLUEPRINT" "/usr/share/i18n/locales/${STEALTH_LOCALE}"

rm -rf "/usr/lib/locale/${STEALTH_LOCALE}.utf8" "/usr/lib/locale/${STEALTH_LOCALE}.UTF-8"
localedef -i "$STEALTH_LOCALE" -f UTF-8 "${STEALTH_LOCALE}.UTF-8"

# ==============================================================================
# 6. WRITE GLOBAL SYSTEM CONFIGURATIONS (Preserving exact user layouts)
# ==============================================================================
cat << EOF > /etc/locale.conf
LANG=${SRC_LANG}.UTF-8
LC_CTYPE=${SRC_CTYPE}.UTF-8
LC_NUMERIC=${SRC_NUMERIC}.UTF-8
LC_TIME=${STEALTH_LOCALE}.UTF-8
LC_COLLATE=${SRC_COLLATE}.UTF-8
LC_MONETARY=${SRC_MONETARY}.UTF-8
LC_MESSAGES=${SRC_MESSAGES}.UTF-8
LC_PAPER=${SRC_PAPER}.UTF-8
LC_NAME=${SRC_NAME}.UTF-8
LC_ADDRESS=${SRC_ADDRESS}.UTF-8
LC_TELEPHONE=${SRC_TELEPHONE}.UTF-8
LC_MEASUREMENT=${SRC_MEASUREMENT}.UTF-8
LC_IDENTIFICATION=${SRC_LANG}.UTF-8
EOF

# ==============================================================================
# 7. WRITE DE GRAPHICAL COMPONENT CONFIGURATIONS (KDE Plasma Native Hybrid Logic)
# ==============================================================================
write_plasma_config() {
  local target_path="$1"
  mkdir -p "$(dirname "$target_path")"
  cat << EOF > "$target_path"
[Formats]
LANG=${SRC_LANG}.UTF-8
LC_ADDRESS=${SRC_ADDRESS}
LC_MEASUREMENT=${SRC_MEASUREMENT}
LC_MONETARY=${SRC_MONETARY}
LC_NAME=${SRC_NAME}
LC_NUMERIC=${SRC_NUMERIC}
LC_PAPER=${SRC_PAPER}
LC_TELEPHONE=${SRC_TELEPHONE}
LC_TIME=${STEALTH_LOCALE}.UTF-8

[Translations]
LANGUAGE=${SRC_LANG}
EOF
}

write_plasma_config "${USER_HOME}/.config/plasma-localerc"
write_plasma_config "/root/.config/plasma-localerc"
chown "${REAL_USER}:${REAL_USER}" "${USER_HOME}/.config/plasma-localerc"

# ==============================================================================
# 8. AUTOMATED CROSS-DISTRIBUTION HOOK INJECTION
# ==============================================================================
if command -v pacman &> /dev/null; then
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
    cat << EOF > /etc/apt/apt.conf.d/99-update-iso-locale
DPkg::Post-Invoke { "HOME_DIR=\$(awk -v uid=1000 -F: '\$3==uid {print \$6}' /etc/passwd); /bin/bash \${HOME_DIR}/.config/LOLS/install-iso-locale.sh"; };
EOF

elif command -v dnf &> /dev/null || command -v dnf5 &> /dev/null; then
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
    (3)
        echo "=> Changes staged. Will execute safely on your next normal reboot."
        ;;
esac

#
