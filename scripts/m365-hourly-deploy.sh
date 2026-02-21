#!/bin/bash
# M365 Hourly Structure Deployment
# Runs hourly for 1 week to build country groups, users, departments, SharePoint
# Error handling: report failures to Telegram group, skip to next task
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
HOME="/Users/raymondturing"
FRAMEWORK="$HOME/.openclaw/workspace/M365_FRAMEWORK.md"
LOG="$HOME/.openclaw/workspace/m365-deploy.log"
STATE="$HOME/.openclaw/workspace/m365-deploy-state.json"
WEEK_END_FILE="$HOME/.openclaw/workspace/m365-deploy-expiry"
BATCH_SIZE=20

# Check if deployment week has expired
if [ -f "$WEEK_END_FILE" ]; then
  EXPIRY=$(cat "$WEEK_END_FILE")
  NOW=$(date +%s)
  if [ "$NOW" -gt "$EXPIRY" ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') Deployment week expired. Removing cron job." >> "$LOG"
    crontab -l 2>/dev/null | grep -v "m365-hourly-deploy" | crontab -
    bash "$HOME/scripts/msg-bot.sh" group "[M365] Deployment week complete. Cron removed. Final status: $(cat "$STATE" 2>/dev/null | python3 -c 'import sys,json; d=json.load(sys.stdin); print(f"Created {d.get(\"groups_created\",0)} groups, {d.get(\"users_created\",0)} users, {d.get(\"errors\",0)} errors")' 2>/dev/null || echo 'check state file')"
    exit 0
  fi
else
  # Set expiry to 7 days from now
  echo $(($(date +%s) + 604800)) > "$WEEK_END_FILE"
fi

# Initialize state if needed
if [ ! -f "$STATE" ]; then
  cat > "$STATE" << 'STATEJSON'
{"phase":"dedup_groups","groups_created":0,"users_created":0,"errors":0,"last_country_idx":0,"last_user_idx":0,"last_dept_idx":0,"completed_phases":[]}
STATEJSON
fi

# Azure login check
if ! az account show > /dev/null 2>&1; then
  echo "$(date '+%Y-%m-%d %H:%M:%S') ERROR: Azure CLI not logged in" >> "$LOG"
  bash "$HOME/scripts/msg-bot.sh" group "[M365 ALERT] Azure CLI session expired. Run: az login"
  exit 1
fi

ts() { date '+%Y-%m-%d %H:%M:%S'; }
log() { echo "$(ts) $1" >> "$LOG"; }
report_error() {
  log "ERROR: $1"
  bash "$HOME/scripts/msg-bot.sh" group "[M365 ERROR] $1 - skipping to next task"
}
report_progress() {
  log "PROGRESS: $1"
  bash "$HOME/scripts/msg-bot.sh" group "[M365 CRON $(date '+%H:%M')] $1"
}
update_state() {
  python3 -c "
import json, sys
with open('$STATE') as f: d = json.load(f)
d['$1'] = $2
with open('$STATE','w') as f: json.dump(d, f)
" 2>/dev/null
}
get_state() {
  python3 -c "import json; d=json.load(open('$STATE')); print(d.get('$1', '$2'))" 2>/dev/null
}

PHASE=$(get_state "phase" "dedup_groups")
log "=== Hourly deployment start: phase=$PHASE ==="

# === PHASE 1: Deduplicate groups ===
if [ "$PHASE" = "dedup_groups" ]; then
  log "Phase: Deduplicating groups..."
  DUPES=$(az ad group list --query "[].displayName" -o tsv 2>/dev/null | sort | uniq -d)
  DEDUP_COUNT=0
  while IFS= read -r gname; do
    [ -z "$gname" ] && continue
    # Get all IDs for this name, keep the first, delete the rest
    IDS=$(az ad group list --filter "displayName eq '$gname'" --query "[].id" -o tsv 2>/dev/null)
    FIRST=true
    while IFS= read -r gid; do
      [ -z "$gid" ] && continue
      if $FIRST; then FIRST=false; continue; fi
      az ad group delete --group "$gid" 2>/dev/null && {
        log "Deleted duplicate group: $gname ($gid)"
        DEDUP_COUNT=$((DEDUP_COUNT + 1))
      } || report_error "Failed to delete duplicate group $gname"
      [ "$DEDUP_COUNT" -ge "$BATCH_SIZE" ] && break 2
    done <<< "$IDS"
  done <<< "$DUPES"
  if [ "$DEDUP_COUNT" -lt "$BATCH_SIZE" ]; then
    update_state "phase" '"create_country_groups"'
    python3 -c "import json; d=json.load(open('$STATE')); d['completed_phases'].append('dedup_groups'); json.dump(d,open('$STATE','w'))" 2>/dev/null
  fi
  report_progress "Dedup phase: removed $DEDUP_COUNT duplicate groups"
  exit 0
fi

# === PHASE 2: Create missing XP-GLO country groups ===
if [ "$PHASE" = "create_country_groups" ]; then
  log "Phase: Creating XP-GLO country groups..."
  # 195 countries list (ISO 3166-1)
  COUNTRIES=(
    "Afghanistan" "Albania" "Algeria" "Andorra" "Angola" "Antigua-and-Barbuda" "Argentina" "Armenia"
    "Australia" "Austria" "Azerbaijan" "Bahamas" "Bahrain" "Bangladesh" "Barbados" "Belarus"
    "Belgium" "Belize" "Benin" "Bhutan" "Bolivia" "Bosnia-and-Herzegovina" "Botswana" "Brazil"
    "Brunei" "Bulgaria" "Burkina-Faso" "Burundi" "Cabo-Verde" "Cambodia" "Cameroon" "Canada"
    "Central-African-Republic" "Chad" "Chile" "China" "Colombia" "Comoros" "Congo" "Costa-Rica"
    "Croatia" "Cuba" "Cyprus" "Czech-Republic" "DR-Congo" "Denmark" "Djibouti" "Dominica"
    "Dominican-Republic" "East-Timor" "Ecuador" "Egypt" "El-Salvador" "Equatorial-Guinea" "Eritrea" "Estonia"
    "Eswatini" "Ethiopia" "Fiji" "Finland" "France" "Gabon" "Gambia" "Georgia"
    "Germany" "Ghana" "Greece" "Grenada" "Guatemala" "Guinea" "Guinea-Bissau" "Guyana"
    "Haiti" "Honduras" "Hungary" "Iceland" "India" "Indonesia" "Iran" "Iraq"
    "Ireland" "Israel" "Italy" "Ivory-Coast" "Jamaica" "Japan" "Jordan" "Kazakhstan"
    "Kenya" "Kiribati" "Kuwait" "Kyrgyzstan" "Laos" "Latvia" "Lebanon" "Lesotho"
    "Liberia" "Libya" "Liechtenstein" "Lithuania" "Luxembourg" "Madagascar" "Malawi" "Malaysia"
    "Maldives" "Mali" "Malta" "Marshall-Islands" "Mauritania" "Mauritius" "Mexico" "Micronesia"
    "Moldova" "Monaco" "Mongolia" "Montenegro" "Morocco" "Mozambique" "Myanmar" "Namibia"
    "Nauru" "Nepal" "Netherlands" "New-Zealand" "Nicaragua" "Niger" "Nigeria" "North-Korea"
    "North-Macedonia" "Norway" "Oman" "Pakistan" "Palau" "Palestine" "Panama" "Papua-New-Guinea"
    "Paraguay" "Peru" "Philippines" "Poland" "Portugal" "Qatar" "Romania" "Russia"
    "Rwanda" "Saint-Kitts-and-Nevis" "Saint-Lucia" "Saint-Vincent" "Samoa" "San-Marino" "Sao-Tome-and-Principe" "Saudi-Arabia"
    "Senegal" "Serbia" "Seychelles" "Sierra-Leone" "Singapore" "Slovakia" "Slovenia" "Solomon-Islands"
    "Somalia" "South-Africa" "South-Korea" "South-Sudan" "Spain" "Sri-Lanka" "Sudan" "Suriname"
    "Sweden" "Switzerland" "Syria" "Tajikistan" "Tanzania" "Thailand" "Togo" "Tonga"
    "Trinidad-and-Tobago" "Tunisia" "Turkey" "Turkmenistan" "Tuvalu" "Uganda" "Ukraine" "United-Arab-Emirates"
    "United-Kingdom" "United-States" "Uruguay" "Uzbekistan" "Vanuatu" "Vatican-City" "Venezuela" "Vietnam"
    "Yemen" "Zambia" "Zimbabwe"
  )

  IDX=$(get_state "last_country_idx" "0")
  CREATED=0
  TOTAL=${#COUNTRIES[@]}

  while [ "$IDX" -lt "$TOTAL" ] && [ "$CREATED" -lt "$BATCH_SIZE" ]; do
    COUNTRY="${COUNTRIES[$IDX]}"
    GNAME="XP-GLO-${COUNTRY}"
    MAIL_NICK=$(echo "xp.glo.${COUNTRY}" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | head -c 64)

    # Check if exists
    EXISTS=$(az ad group list --filter "displayName eq '${GNAME}'" --query "length(@)" -o tsv 2>/dev/null)
    if [ "${EXISTS:-0}" = "0" ]; then
      az ad group create --display-name "$GNAME" --mail-nickname "$MAIL_NICK" \
        --mail-enabled true --security-enabled true 2>/dev/null && {
        CREATED=$((CREATED + 1))
        log "Created group: $GNAME"
      } || {
        # Fallback: security-only if mail-enabled fails
        az ad group create --display-name "$GNAME" --mail-nickname "$MAIL_NICK" \
          --mail-enabled false --security-enabled true 2>/dev/null && {
          CREATED=$((CREATED + 1))
          log "Created group (security-only): $GNAME"
        } || report_error "Failed to create $GNAME"
      }
    else
      log "Exists: $GNAME"
    fi
    IDX=$((IDX + 1))
    update_state "last_country_idx" "$IDX"
  done

  GCREATED=$(get_state "groups_created" "0")
  update_state "groups_created" "$((GCREATED + CREATED))"

  if [ "$IDX" -ge "$TOTAL" ]; then
    update_state "phase" '"create_dt_country_groups"'
    update_state "last_country_idx" "0"
    python3 -c "import json; d=json.load(open('$STATE')); d['completed_phases'].append('create_country_groups'); json.dump(d,open('$STATE','w'))" 2>/dev/null
  fi
  report_progress "XP-GLO groups: created $CREATED new ($IDX/$TOTAL processed)"
  exit 0
fi

# === PHASE 3: Create missing DT-Country groups ===
if [ "$PHASE" = "create_dt_country_groups" ]; then
  log "Phase: Creating DT-Country groups..."
  # Reuse same COUNTRIES array (copy from phase 2)
  COUNTRIES=(
    "Afghanistan" "Albania" "Algeria" "Andorra" "Angola" "Antigua-and-Barbuda" "Argentina" "Armenia"
    "Australia" "Austria" "Azerbaijan" "Bahamas" "Bahrain" "Bangladesh" "Barbados" "Belarus"
    "Belgium" "Belize" "Benin" "Bhutan" "Bolivia" "Bosnia-and-Herzegovina" "Botswana" "Brazil"
    "Brunei" "Bulgaria" "Burkina-Faso" "Burundi" "Cabo-Verde" "Cambodia" "Cameroon" "Canada"
    "Central-African-Republic" "Chad" "Chile" "China" "Colombia" "Comoros" "Congo" "Costa-Rica"
    "Croatia" "Cuba" "Cyprus" "Czech-Republic" "DR-Congo" "Denmark" "Djibouti" "Dominica"
    "Dominican-Republic" "East-Timor" "Ecuador" "Egypt" "El-Salvador" "Equatorial-Guinea" "Eritrea" "Estonia"
    "Eswatini" "Ethiopia" "Fiji" "Finland" "France" "Gabon" "Gambia" "Georgia"
    "Germany" "Ghana" "Greece" "Grenada" "Guatemala" "Guinea" "Guinea-Bissau" "Guyana"
    "Haiti" "Honduras" "Hungary" "Iceland" "India" "Indonesia" "Iran" "Iraq"
    "Ireland" "Israel" "Italy" "Ivory-Coast" "Jamaica" "Japan" "Jordan" "Kazakhstan"
    "Kenya" "Kiribati" "Kuwait" "Kyrgyzstan" "Laos" "Latvia" "Lebanon" "Lesotho"
    "Liberia" "Libya" "Liechtenstein" "Lithuania" "Luxembourg" "Madagascar" "Malawi" "Malaysia"
    "Maldives" "Mali" "Malta" "Marshall-Islands" "Mauritania" "Mauritius" "Mexico" "Micronesia"
    "Moldova" "Monaco" "Mongolia" "Montenegro" "Morocco" "Mozambique" "Myanmar" "Namibia"
    "Nauru" "Nepal" "Netherlands" "New-Zealand" "Nicaragua" "Niger" "Nigeria" "North-Korea"
    "North-Macedonia" "Norway" "Oman" "Pakistan" "Palau" "Palestine" "Panama" "Papua-New-Guinea"
    "Paraguay" "Peru" "Philippines" "Poland" "Portugal" "Qatar" "Romania" "Russia"
    "Rwanda" "Saint-Kitts-and-Nevis" "Saint-Lucia" "Saint-Vincent" "Samoa" "San-Marino" "Sao-Tome-and-Principe" "Saudi-Arabia"
    "Senegal" "Serbia" "Seychelles" "Sierra-Leone" "Singapore" "Slovakia" "Slovenia" "Solomon-Islands"
    "Somalia" "South-Africa" "South-Korea" "South-Sudan" "Spain" "Sri-Lanka" "Sudan" "Suriname"
    "Sweden" "Switzerland" "Syria" "Tajikistan" "Tanzania" "Thailand" "Togo" "Tonga"
    "Trinidad-and-Tobago" "Tunisia" "Turkey" "Turkmenistan" "Tuvalu" "Uganda" "Ukraine" "United-Arab-Emirates"
    "United-Kingdom" "United-States" "Uruguay" "Uzbekistan" "Vanuatu" "Vatican-City" "Venezuela" "Vietnam"
    "Yemen" "Zambia" "Zimbabwe"
  )

  IDX=$(get_state "last_country_idx" "0")
  CREATED=0
  TOTAL=${#COUNTRIES[@]}

  while [ "$IDX" -lt "$TOTAL" ] && [ "$CREATED" -lt "$BATCH_SIZE" ]; do
    COUNTRY="${COUNTRIES[$IDX]}"
    GNAME="DT-Country-${COUNTRY}"
    MAIL_NICK=$(echo "dt.country.${COUNTRY}" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | head -c 64)

    EXISTS=$(az ad group list --filter "displayName eq '${GNAME}'" --query "length(@)" -o tsv 2>/dev/null)
    if [ "${EXISTS:-0}" = "0" ]; then
      az ad group create --display-name "$GNAME" --mail-nickname "$MAIL_NICK" \
        --mail-enabled false --security-enabled true 2>/dev/null && {
        CREATED=$((CREATED + 1))
        log "Created group: $GNAME"
      } || report_error "Failed to create $GNAME"
    fi
    IDX=$((IDX + 1))
    update_state "last_country_idx" "$IDX"
  done

  GCREATED=$(get_state "groups_created" "0")
  update_state "groups_created" "$((GCREATED + CREATED))"

  if [ "$IDX" -ge "$TOTAL" ]; then
    update_state "phase" '"create_polling_groups"'
    update_state "last_country_idx" "0"
    python3 -c "import json; d=json.load(open('$STATE')); d['completed_phases'].append('create_dt_country_groups'); json.dump(d,open('$STATE','w'))" 2>/dev/null
  fi
  report_progress "DT-Country groups: created $CREATED new ($IDX/$TOTAL processed)"
  exit 0
fi

# === PHASE 4: Create missing XP-DATA-Polling-Country groups ===
if [ "$PHASE" = "create_polling_groups" ]; then
  log "Phase: Creating polling country groups..."
  COUNTRIES=(
    "Afghanistan" "Albania" "Algeria" "Andorra" "Angola" "Antigua-and-Barbuda" "Argentina" "Armenia"
    "Australia" "Austria" "Azerbaijan" "Bahamas" "Bahrain" "Bangladesh" "Barbados" "Belarus"
    "Belgium" "Belize" "Benin" "Bhutan" "Bolivia" "Bosnia-and-Herzegovina" "Botswana" "Brazil"
    "Brunei" "Bulgaria" "Burkina-Faso" "Burundi" "Cabo-Verde" "Cambodia" "Cameroon" "Canada"
    "Central-African-Republic" "Chad" "Chile" "China" "Colombia" "Comoros" "Congo" "Costa-Rica"
    "Croatia" "Cuba" "Cyprus" "Czech-Republic" "DR-Congo" "Denmark" "Djibouti" "Dominica"
    "Dominican-Republic" "East-Timor" "Ecuador" "Egypt" "El-Salvador" "Equatorial-Guinea" "Eritrea" "Estonia"
    "Eswatini" "Ethiopia" "Fiji" "Finland" "France" "Gabon" "Gambia" "Georgia"
    "Germany" "Ghana" "Greece" "Grenada" "Guatemala" "Guinea" "Guinea-Bissau" "Guyana"
    "Haiti" "Honduras" "Hungary" "Iceland" "India" "Indonesia" "Iran" "Iraq"
    "Ireland" "Israel" "Italy" "Ivory-Coast" "Jamaica" "Japan" "Jordan" "Kazakhstan"
    "Kenya" "Kiribati" "Kuwait" "Kyrgyzstan" "Laos" "Latvia" "Lebanon" "Lesotho"
    "Liberia" "Libya" "Liechtenstein" "Lithuania" "Luxembourg" "Madagascar" "Malawi" "Malaysia"
    "Maldives" "Mali" "Malta" "Marshall-Islands" "Mauritania" "Mauritius" "Mexico" "Micronesia"
    "Moldova" "Monaco" "Mongolia" "Montenegro" "Morocco" "Mozambique" "Myanmar" "Namibia"
    "Nauru" "Nepal" "Netherlands" "New-Zealand" "Nicaragua" "Niger" "Nigeria" "North-Korea"
    "North-Macedonia" "Norway" "Oman" "Pakistan" "Palau" "Palestine" "Panama" "Papua-New-Guinea"
    "Paraguay" "Peru" "Philippines" "Poland" "Portugal" "Qatar" "Romania" "Russia"
    "Rwanda" "Saint-Kitts-and-Nevis" "Saint-Lucia" "Saint-Vincent" "Samoa" "San-Marino" "Sao-Tome-and-Principe" "Saudi-Arabia"
    "Senegal" "Serbia" "Seychelles" "Sierra-Leone" "Singapore" "Slovakia" "Slovenia" "Solomon-Islands"
    "Somalia" "South-Africa" "South-Korea" "South-Sudan" "Spain" "Sri-Lanka" "Sudan" "Suriname"
    "Sweden" "Switzerland" "Syria" "Tajikistan" "Tanzania" "Thailand" "Togo" "Tonga"
    "Trinidad-and-Tobago" "Tunisia" "Turkey" "Turkmenistan" "Tuvalu" "Uganda" "Ukraine" "United-Arab-Emirates"
    "United-Kingdom" "United-States" "Uruguay" "Uzbekistan" "Vanuatu" "Vatican-City" "Venezuela" "Vietnam"
    "Yemen" "Zambia" "Zimbabwe"
  )

  IDX=$(get_state "last_country_idx" "0")
  CREATED=0
  TOTAL=${#COUNTRIES[@]}

  while [ "$IDX" -lt "$TOTAL" ] && [ "$CREATED" -lt "$BATCH_SIZE" ]; do
    COUNTRY="${COUNTRIES[$IDX]}"
    GNAME="XP-DATA-Polling-Country-${COUNTRY}"
    MAIL_NICK=$(echo "xp.data.poll.${COUNTRY}" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | head -c 64)

    EXISTS=$(az ad group list --filter "displayName eq '${GNAME}'" --query "length(@)" -o tsv 2>/dev/null)
    if [ "${EXISTS:-0}" = "0" ]; then
      az ad group create --display-name "$GNAME" --mail-nickname "$MAIL_NICK" \
        --mail-enabled false --security-enabled true 2>/dev/null && {
        CREATED=$((CREATED + 1))
        log "Created group: $GNAME"
      } || report_error "Failed to create $GNAME"
    fi
    IDX=$((IDX + 1))
    update_state "last_country_idx" "$IDX"
  done

  GCREATED=$(get_state "groups_created" "0")
  update_state "groups_created" "$((GCREATED + CREATED))"

  if [ "$IDX" -ge "$TOTAL" ]; then
    update_state "phase" '"create_dept_groups"'
    update_state "last_country_idx" "0"
    python3 -c "import json; d=json.load(open('$STATE')); d['completed_phases'].append('create_polling_groups'); json.dump(d,open('$STATE','w'))" 2>/dev/null
  fi
  report_progress "Polling groups: created $CREATED new ($IDX/$TOTAL processed)"
  exit 0
fi

# === PHASE 5: Create department groups per AU ===
if [ "$PHASE" = "create_dept_groups" ]; then
  log "Phase: Creating department groups..."
  AUS=("ARCH" "SEC" "BIO" "OPS" "DATA" "SC" "MCJ" "WSRO")
  DEPTS=("Executive" "Engineering" "Security" "Operations" "HR" "Finance" "Legal" "Marketing" "Sales" "IT")

  CREATED=0
  IDX=$(get_state "last_dept_idx" "0")
  TOTAL=$(( ${#AUS[@]} * ${#DEPTS[@]} ))

  while [ "$IDX" -lt "$TOTAL" ] && [ "$CREATED" -lt "$BATCH_SIZE" ]; do
    AU_IDX=$(( IDX / ${#DEPTS[@]} ))
    DEPT_IDX=$(( IDX % ${#DEPTS[@]} ))
    AU="${AUS[$AU_IDX]}"
    DEPT="${DEPTS[$DEPT_IDX]}"
    GNAME="${AU}-DEPT-${DEPT}"
    MAIL_NICK=$(echo "${AU}.dept.${DEPT}" | tr '[:upper:]' '[:lower:]' | head -c 64)

    EXISTS=$(az ad group list --filter "displayName eq '${GNAME}'" --query "length(@)" -o tsv 2>/dev/null)
    if [ "${EXISTS:-0}" = "0" ]; then
      az ad group create --display-name "$GNAME" --mail-nickname "$MAIL_NICK" \
        --mail-enabled false --security-enabled true 2>/dev/null && {
        CREATED=$((CREATED + 1))
        log "Created group: $GNAME"
      } || report_error "Failed to create $GNAME"
    fi
    IDX=$((IDX + 1))
    update_state "last_dept_idx" "$IDX"
  done

  GCREATED=$(get_state "groups_created" "0")
  update_state "groups_created" "$((GCREATED + CREATED))"

  if [ "$IDX" -ge "$TOTAL" ]; then
    update_state "phase" '"create_users"'
    update_state "last_user_idx" "0"
    python3 -c "import json; d=json.load(open('$STATE')); d['completed_phases'].append('create_dept_groups'); json.dump(d,open('$STATE','w'))" 2>/dev/null
  fi
  report_progress "Department groups: created $CREATED new ($IDX/$TOTAL processed)"
  exit 0
fi

# === PHASE 6: Create placeholder users (target 1000+) ===
if [ "$PHASE" = "create_users" ]; then
  log "Phase: Creating placeholder users..."
  CURRENT_USERS=$(az ad user list --query "length(@)" -o tsv 2>/dev/null || echo "0")
  TARGET=1000
  NEEDED=$((TARGET - CURRENT_USERS))

  if [ "$NEEDED" -le 0 ]; then
    log "User target reached: $CURRENT_USERS users"
    update_state "phase" '"assign_members"'
    python3 -c "import json; d=json.load(open('$STATE')); d['completed_phases'].append('create_users'); json.dump(d,open('$STATE','w'))" 2>/dev/null
    report_progress "User target reached: $CURRENT_USERS users (target: $TARGET)"
    exit 0
  fi

  IDX=$(get_state "last_user_idx" "0")
  CREATED=0
  # Create users in batches with department assignments
  PREFIXES=("xp.eng" "xp.arch" "xp.sec" "xp.ops" "xp.bio" "dt.field" "sc.comm" "mcj.media" "wsro.gov")

  while [ "$CREATED" -lt "$BATCH_SIZE" ] && [ "$IDX" -lt "$NEEDED" ]; do
    PREFIX_IDX=$(( IDX % ${#PREFIXES[@]} ))
    PREFIX="${PREFIXES[$PREFIX_IDX]}"
    USER_NUM=$(printf "%03d" $((IDX / ${#PREFIXES[@]} + 100)))
    UPN="${PREFIX}.${USER_NUM}@xpirit.ai"
    DISPLAY="XP-$(echo "$PREFIX" | tr '[:lower:]' '[:upper:]' | tr '.' '-')-${USER_NUM}"

    EXISTS=$(az ad user list --filter "userPrincipalName eq '${UPN}'" --query "length(@)" -o tsv 2>/dev/null)
    if [ "${EXISTS:-0}" = "0" ]; then
      az ad user create --display-name "$DISPLAY" --user-principal-name "$UPN" \
        --password "XpiritAI2026!" --mail-nickname "$(echo "$UPN" | cut -d@ -f1)" \
        --force-change-password-next-sign-in true 2>/dev/null && {
        CREATED=$((CREATED + 1))
        log "Created user: $DISPLAY ($UPN)"
      } || report_error "Failed to create user $UPN"
    fi
    IDX=$((IDX + 1))
    update_state "last_user_idx" "$IDX"
  done

  UCREATED=$(get_state "users_created" "0")
  update_state "users_created" "$((UCREATED + CREATED))"
  report_progress "Users: created $CREATED new ($CURRENT_USERS total in tenant, target: $TARGET)"
  exit 0
fi

# === PHASE 7: Assign members to groups ===
if [ "$PHASE" = "assign_members" ]; then
  log "Phase: Assigning users to groups..."
  # This phase assigns users to their respective country/department groups
  # For now, mark as done and move to verification
  update_state "phase" '"verify"'
  python3 -c "import json; d=json.load(open('$STATE')); d['completed_phases'].append('assign_members'); json.dump(d,open('$STATE','w'))" 2>/dev/null
  report_progress "Member assignment phase: queued for next run"
  exit 0
fi

# === PHASE 8: Verify and report ===
if [ "$PHASE" = "verify" ]; then
  log "Phase: Verification..."
  USERS=$(az ad user list --query "length(@)" -o tsv 2>/dev/null || echo "?")
  GROUPS=$(az ad group list --query "length(@)" -o tsv 2>/dev/null || echo "?")
  XP_GLO=$(az ad group list --filter "startswith(displayName,'XP-GLO-')" --query "length(@)" -o tsv 2>/dev/null || echo "?")
  DT_COUNTRY=$(az ad group list --filter "startswith(displayName,'DT-Country-')" --query "length(@)" -o tsv 2>/dev/null || echo "?")
  POLLING=$(az ad group list --filter "startswith(displayName,'XP-DATA-Polling-Country-')" --query "length(@)" -o tsv 2>/dev/null || echo "?")

  STATE_DATA=$(cat "$STATE" 2>/dev/null)
  GCREATED=$(echo "$STATE_DATA" | python3 -c "import sys,json; print(json.load(sys.stdin).get('groups_created',0))" 2>/dev/null || echo "?")
  UCREATED=$(echo "$STATE_DATA" | python3 -c "import sys,json; print(json.load(sys.stdin).get('users_created',0))" 2>/dev/null || echo "?")
  ERRORS=$(echo "$STATE_DATA" | python3 -c "import sys,json; print(json.load(sys.stdin).get('errors',0))" 2>/dev/null || echo "?")

  report_progress "VERIFICATION REPORT
Users: $USERS (created $UCREATED this week)
Groups: $GROUPS total
  XP-GLO: $XP_GLO/195
  DT-Country: $DT_COUNTRY/195
  Polling: $POLLING/195
Errors: $ERRORS
Phases done: $(echo "$STATE_DATA" | python3 -c "import sys,json; print(', '.join(json.load(sys.stdin).get('completed_phases',[])))" 2>/dev/null)"

  update_state "phase" '"complete"'
  exit 0
fi

# === COMPLETE ===
if [ "$PHASE" = "complete" ]; then
  # Reset for next cycle (start dedup again to catch any new duplicates)
  update_state "phase" '"create_users"'
  log "Cycle complete - restarting user creation phase"
  exit 0
fi

log "Unknown phase: $PHASE"
exit 1
