#!/usr/bin/env bash

# Custom ISO-8601 Engine Blueprint (Tony Advantaged)
# Strict glibc compilation compliance template

if [ "$EUID" -ne 0 ]; then
  echo "Error: This installer must be run as root (sudo)."
  exit 1
fi

# ==============================================================================
# 1. DYNAMIC SYSTEM MATRIX DISCOVERY
# ==============================================================================
REAL_USER="${SUDO_USER:-$USER}"
if [ "$REAL_USER" = "root" ]; then
  REAL_USER=$(awk -v uid=1000 -F: '$3==uid {print $1}' /etc/passwd)
fi
USER_HOME=$(eval echo "~$REAL_USER")
LOLS_DIR="${USER_HOME}/.config/LOLS"
SOURCE_BLUEPRINT="${LOLS_DIR}/en_ISO.locale"

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

if [ -d "$LOLS_DIR" ]; then
    rm -rf "${LOLS_DIR:?}"/*
else
    mkdir -p "$LOLS_DIR"
fi

# ==============================================================================
# 2. STEALTH CONTAINER VEHICLE SELECTION
# ==============================================================================
STEALTH_LOCALE="en_IE"
current_time_locale=$(env | grep LC_TIME | cut -d= -f2 | cut -d. -f1)

if [[ "$current_time_locale" == "en_IE" ]]; then
    STEALTH_LOCALE="en_GB"
elif [[ "$current_time_locale" == "en_GB" ]]; then
    STEALTH_LOCALE="en_AU"
fi

TARGET_TERRITORY="${STEALTH_LOCALE#*_}"

# ==============================================================================
# 3. SURGICAL EXTRACTION OF TEXT STRINGS (Defeating glibc copy bugs)
# ==============================================================================
SRC_LOCALE_FILE="/usr/share/i18n/locales/${SRC_TIME}"
if [ ! -f "$SRC_LOCALE_FILE" ]; then
    SRC_LOCALE_FILE="/usr/share/i18n/locales/$(echo "${SRC_TIME}" | cut -d@ -f1)"
fi

if [ -f "$SRC_LOCALE_FILE" ]; then
    NATIVE_DAYS=$(sed -n '/^LC_TIME/,/^END LC_TIME/p' "$SRC_LOCALE_FILE" | grep -E '^(abday|day)[[:space:]]')
    NATIVE_MONTHS=$(sed -n '/^LC_TIME/,/^END LC_TIME/p' "$SRC_LOCALE_FILE" | grep -E '^(abmon|mon)[[:space:]]')
else
    NATIVE_DAYS=$'abday   "Sun";"Mon";"Tue";"Wed";"Thu";"Fri";"Sat"\nday     "Sunday";"Monday";"Tuesday";"Wednesday";"Thursday";"Friday";"Saturday"'
    NATIVE_MONTHS=$'abmon   "Jan";"Feb";"Mar";"Apr";"May";"Jun";"Jul";"Aug";"Sep";"Oct";"Nov";"Dec"\nmon     "January";"February";"March";"April";"May";"June";"July";"August";"September";"October";"November";"December"'
fi

# ==============================================================================
# 4. BLUEPRINT COMPILATION WITH STRICT GLIBC COMMENT METRICS
# ==============================================================================
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
revision   "1.3"
date       "2026-06-01"
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
% Native text calendar structures injected manually from background profiles
${NATIVE_DAYS}
${NATIVE_MONTHS}

% Surgical overwrite of temporal rendering blocks for explicit ISO metrics
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
# 5. INJECT INTO SYSTEM DIRECTORIES AND RUN BINARY LOCALEDEF
# ==============================================================================
[ -f /etc/locale.conf ] && chattr -i /etc/locale.conf
[ -f "${USER_HOME}/.config/plasma-localerc" ] && chattr -i "${USER_HOME}/.config/plasma-localerc"

if [ -f /etc/locale.gen ]; then
    sed -i "/^#\?${STEALTH_LOCALE}.UTF-8/d" /etc/locale.gen
    echo "${STEALTH_LOCALE}.UTF-8 UTF-8" >> /etc/locale.gen
fi

rm -f "/usr/share/i18n/locales/${STEALTH_LOCALE}"
cp "$SOURCE_BLUEPRINT" "/usr/share/i18n/locales/${STEALTH_LOCALE}"

rm -rf "/usr/lib/locale/${STEALTH_LOCALE}.utf8" "/usr/lib/locale/${STEALTH_LOCALE}.UTF-8"
localedef -i "$STEALTH_LOCALE" -f UTF-8 "${STEALTH_LOCALE}.UTF-8"

# ==============================================================================
# 6. ENFORCE SYSTEM EMBEDDED PATHS
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

# Auto-deploy the ALPM pacman core hook for Arch/CachyOS updates
mkdir -p /etc/pacman.d/hooks
cat << 'EOF' > /etc/pacman.d/hooks/99-update-iso-locale.hook
[Trigger]
Operation = Install
Operation = Upgrade
Type = Package
Target = glibc
Target = glibc-locales

[Action]
Description = Re-compiling custom ISO-8601 system locale configurations via Pacman Hook...
When = PostTransaction
Depends = bash
Exec = /bin/bash -c "HOME_DIR=\$(awk -v uid=1000 -F: '\$3==uid {print \$6}' /etc/passwd); /bin/bash \${HOME_DIR}/.config/LOLS/install-iso-locale.sh"
EOF

cp "$0" "${LOLS_DIR}/install-iso-locale.sh" 2>/dev/null || true
chmod +x "${LOLS_DIR}/install-iso-locale.sh" 2>/dev/null || true

echo "=> Script execution complete. Arch-subsystem configuration successfully targeted."

#
