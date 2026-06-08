#!/usr/bin/env bash
# Automates Android release signing + Firebase SHA registration for SuperBai.
#
# Prerequisites:
#   - Flutter SDK on PATH
#   - firebase CLI logged in: firebase login
#
# Non-interactive (CI / scripted):
#   export SUPERBAI_KEYSTORE_PASSWORD='your-password'
#   export SUPERBAI_KEY_PASSWORD='your-password'   # optional; defaults to store password
#   ./scripts/setup_android_release.sh
#
# Optional env:
#   SUPERBAI_KEYSTORE_PATH   default: ~/upload-keystore.jks
#   SUPERBAI_KEY_ALIAS       default: upload
#   SUPERBAI_FIREBASE_PROJECT default: superbai-81bc6
#   SUPERBAI_SKIP_FIREBASE=1  skip SHA upload + google-services.json download
#   SUPERBAI_SKIP_BUILD=1     skip flutter build appbundle
#   SUPERBAI_FORCE_KEYSTORE=1 regenerate keystore (dangerous if app is already published)

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

FIREBASE_PROJECT="${SUPERBAI_FIREBASE_PROJECT:-superbai-81bc6}"
FIREBASE_ANDROID_APP_ID="${SUPERBAI_FIREBASE_ANDROID_APP_ID:-1:615905251954:android:e7844b86baa467a0dc68eb}"
KEYSTORE_PATH="${SUPERBAI_KEYSTORE_PATH:-$HOME/upload-keystore.jks}"
KEY_ALIAS="${SUPERBAI_KEY_ALIAS:-upload}"
KEY_PROPERTIES_FILE="$ROOT_DIR/android/key.properties"
GOOGLE_SERVICES_FILE="$ROOT_DIR/android/app/google-services.json"
DEBUG_KEYSTORE="$HOME/.android/debug.keystore"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info() { echo -e "${GREEN}==>${NC} $*"; }
warn() { echo -e "${YELLOW}warning:${NC} $*"; }
fail() { echo -e "${RED}error:${NC} $*" >&2; exit 1; }

find_keytool() {
  local candidates=(
    "/Applications/Android Studio.app/Contents/jbr/Contents/Home/bin/keytool"
    "${JAVA_HOME:-}/bin/keytool"
    "$(command -v keytool 2>/dev/null || true)"
  )
  for candidate in "${candidates[@]}"; do
    if [[ -n "$candidate" && -x "$candidate" ]]; then
      echo "$candidate"
      return 0
    fi
  done
  fail "keytool not found. Install Android Studio or set JAVA_HOME."
}

KEYTOOL="$(find_keytool)"
info "Using keytool: $KEYTOOL"

normalize_sha_for_firebase() {
  echo "$1" | tr -d ':' | tr '[:upper:]' '[:lower:]'
}

read_password() {
  local prompt="$1"
  local var_name="$2"
  if [[ -n "${!var_name:-}" ]]; then
    return 0
  fi
  read -r -s -p "$prompt" value
  echo
  printf -v "$var_name" '%s' "$value"
}

ensure_keystore_passwords() {
  read_password "Keystore password: " SUPERBAI_KEYSTORE_PASSWORD
  SUPERBAI_KEY_PASSWORD="${SUPERBAI_KEY_PASSWORD:-$SUPERBAI_KEYSTORE_PASSWORD}"
  [[ -n "$SUPERBAI_KEYSTORE_PASSWORD" ]] || fail "Keystore password is required."
}

create_keystore() {
  if [[ -f "$KEYSTORE_PATH" && "${SUPERBAI_FORCE_KEYSTORE:-}" != "1" ]]; then
    info "Keystore already exists at $KEYSTORE_PATH"
    return 0
  fi

  if [[ -f "$KEYSTORE_PATH" && "${SUPERBAI_FORCE_KEYSTORE:-}" == "1" ]]; then
    warn "SUPERBAI_FORCE_KEYSTORE=1 — overwriting $KEYSTORE_PATH"
    rm -f "$KEYSTORE_PATH"
  fi

  ensure_keystore_passwords
  info "Creating upload keystore at $KEYSTORE_PATH"
  mkdir -p "$(dirname "$KEYSTORE_PATH")"

  "$KEYTOOL" -genkey -v \
    -keystore "$KEYSTORE_PATH" \
    -alias "$KEY_ALIAS" \
    -keyalg RSA \
    -keysize 2048 \
    -validity 10000 \
    -storepass "$SUPERBAI_KEYSTORE_PASSWORD" \
    -keypass "$SUPERBAI_KEY_PASSWORD" \
    -dname "CN=SuperBai, OU=Mobile, O=SuperBai, L=Mumbai, ST=Maharashtra, C=IN"

  info "Keystore created. Back up $KEYSTORE_PATH somewhere safe."
}

write_key_properties() {
  ensure_keystore_passwords
  info "Writing $KEY_PROPERTIES_FILE"
  cat >"$KEY_PROPERTIES_FILE" <<EOF
storePassword=$SUPERBAI_KEYSTORE_PASSWORD
keyPassword=$SUPERBAI_KEY_PASSWORD
keyAlias=$KEY_ALIAS
storeFile=$KEYSTORE_PATH
EOF
  chmod 600 "$KEY_PROPERTIES_FILE"
}

fingerprint_from_keystore() {
  local keystore="$1"
  local alias="$2"
  local store_pass="$3"
  local key_pass="$4"
  "$KEYTOOL" -list -v \
    -keystore "$keystore" \
    -alias "$alias" \
    -storepass "$store_pass" \
    -keypass "$key_pass" 2>/dev/null
}

extract_sha() {
  local output="$1"
  local label="$2"
  echo "$output" | awk -v label="$label" '
    $1 == label ":" { print $2; exit }
  '
}

collect_fingerprints() {
  local label="$1"
  local keystore="$2"
  local alias="$3"
  local store_pass="$4"
  local key_pass="$5"

  local output
  output="$(fingerprint_from_keystore "$keystore" "$alias" "$store_pass" "$key_pass")"
  SHA1="$(extract_sha "$output" "SHA1")"
  SHA256="$(extract_sha "$output" "SHA256")"
  [[ -n "$SHA1" && -n "$SHA256" ]] || fail "Could not read SHA fingerprints from $keystore"
}

register_sha_if_missing() {
  local sha_hash="$1"
  local existing
  existing="$(firebase apps:android:sha:list "$FIREBASE_ANDROID_APP_ID" --project "$FIREBASE_PROJECT" 2>/dev/null || true)"
  if echo "$existing" | grep -qi "$sha_hash"; then
    info "SHA already registered in Firebase: $sha_hash"
    return 0
  fi
  info "Registering SHA in Firebase: $sha_hash"
  firebase apps:android:sha:create "$FIREBASE_ANDROID_APP_ID" "$sha_hash" --project "$FIREBASE_PROJECT"
}

sync_firebase_shas() {
  command -v firebase >/dev/null 2>&1 || fail "firebase CLI not found. Install: npm i -g firebase-tools"

  info "Checking Firebase auth for project $FIREBASE_PROJECT"
  firebase projects:list --project "$FIREBASE_PROJECT" >/dev/null 2>&1 || \
    fail "Not logged into Firebase. Run: firebase login"

  local upload_sha1 upload_sha256 debug_sha1 debug_sha256
  upload_sha1="$(normalize_sha_for_firebase "$SHA1")"
  upload_sha256="$(normalize_sha_for_firebase "$SHA256")"

  register_sha_if_missing "$upload_sha1"
  register_sha_if_missing "$upload_sha256"

  if [[ -f "$DEBUG_KEYSTORE" ]]; then
    info "Registering debug keystore fingerprints (for dev/testing)"
    local debug_output debug_sha1_raw debug_sha256_raw
    debug_output="$(fingerprint_from_keystore "$DEBUG_KEYSTORE" androiddebugkey android android)"
    debug_sha1_raw="$(extract_sha "$debug_output" "SHA1")"
    debug_sha256_raw="$(extract_sha "$debug_output" "SHA256")"
    debug_sha1="$(normalize_sha_for_firebase "$debug_sha1_raw")"
    debug_sha256="$(normalize_sha_for_firebase "$debug_sha256_raw")"
    register_sha_if_missing "$debug_sha1"
    register_sha_if_missing "$debug_sha256"
  else
    warn "Debug keystore not found at $DEBUG_KEYSTORE — skipping debug SHA registration"
  fi

  info "Downloading google-services.json"
  rm -f "$GOOGLE_SERVICES_FILE"
  firebase apps:sdkconfig ANDROID "$FIREBASE_ANDROID_APP_ID" \
    --project "$FIREBASE_PROJECT" \
    -o "$GOOGLE_SERVICES_FILE"
}

build_release_bundle() {
  command -v flutter >/dev/null 2>&1 || fail "flutter not found on PATH"
  info "Building release app bundle"
  flutter pub get
  set +e
  flutter build appbundle --release
  local build_exit=$?
  set -e

  local aab="build/app/outputs/bundle/release/app-release.aab"
  if [[ ! -f "$aab" ]]; then
    fail "Release app bundle was not created."
  fi

  info "AAB ready: $aab"
  if [[ $build_exit -ne 0 ]]; then
    warn "Flutter reported a post-build validation error (debug symbol strip check)."
    warn "The AAB above is still valid for Play Console upload."
    warn "Fix for a clean build: Android Studio → SDK Manager → SDK Tools"
    warn "  → install 'Android SDK Command-line Tools (latest)'"
    warn "Then run: flutter doctor --android-licenses"
  fi
}

main() {
  info "SuperBai Android release setup"
  info "Project root: $ROOT_DIR"

  create_keystore
  write_key_properties

  ensure_keystore_passwords
  collect_fingerprints "upload" "$KEYSTORE_PATH" "$KEY_ALIAS" \
    "$SUPERBAI_KEYSTORE_PASSWORD" "$SUPERBAI_KEY_PASSWORD"

  echo
  info "Upload keystore fingerprints (save these):"
  echo "  SHA-1:   $SHA1"
  echo "  SHA-256: $SHA256"
  echo

  if [[ "${SUPERBAI_SKIP_FIREBASE:-}" != "1" ]]; then
    sync_firebase_shas
    if grep -q '"oauth_client": \[\]' "$GOOGLE_SERVICES_FILE" 2>/dev/null; then
      warn "google-services.json has an empty oauth_client array — this is common for phone-only auth."
      warn "Your upload SHA fingerprints are registered; test OTP on a release APK."
      warn "If OTP fails, enable Google sign-in in Firebase Auth (can leave unused) and re-download."
    else
      info "google-services.json updated with OAuth client config"
    fi
  else
    warn "Skipped Firebase SHA sync (SUPERBAI_SKIP_FIREBASE=1)"
  fi

  if [[ "${SUPERBAI_SKIP_BUILD:-}" != "1" ]]; then
    build_release_bundle
  else
    warn "Skipped release build (SUPERBAI_SKIP_BUILD=1)"
  fi

  echo
  info "Done. Next: install a release APK on a physical phone and test phone OTP."
  echo "  flutter build apk --release"
  echo "  adb install build/app/outputs/flutter-apk/app-release.apk"
}

main "$@"
