#!/usr/bin/env bash
# Guard for the public CV build: assert that nothing private shipped.
#
#   scripts/check-no-private.sh [_site]
#
# Fails if:
#   - resume-public.pdf is missing from the artifact directory
#   - the artifact directory contains phone.tex or resume.pdf (private inputs)
#   - the public PDF (text and raw bytes) contains the private phone number
#   - the LaTeX log for the public build contains the private phone number
#
# The phone number itself is never printed: all messages are redacted.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ARTIFACT_DIR="${1:-$ROOT/_site}"
PDF="$ARTIFACT_DIR/resume-public.pdf"
PHONE_TEX="$ROOT/phone.tex"

fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }
ok() { printf 'ok: %s\n' "$*"; }
warn() { printf 'warn: %s\n' "$*" >&2; }

[[ -d "$ARTIFACT_DIR" ]] || fail "artifact directory not found: $ARTIFACT_DIR"
[[ -f "$PDF" ]] || fail "missing public artifact: $PDF"
ok "public artifact present: ${PDF#"$ROOT"/}"

# ---- 1. no private files inside the published directory --------------------
for forbidden in phone.tex resume.pdf; do
  hit="$(find "$ARTIFACT_DIR" -name "$forbidden" -print -quit)"
  [[ -z "$hit" ]] || fail "private file leaked into artifact dir: ${hit#"$ARTIFACT_DIR"/}"
done
ok "artifact dir contains no phone.tex / resume.pdf"

# ---- 2. derive the private phone digits (never printed) --------------------
phone_digits=""
if [[ -f "$PHONE_TEX" ]]; then
  # first non-comment line that defines \contactphone, reduced to digits only
  phone_line="$(grep -v '^[[:space:]]*%' "$PHONE_TEX" | grep -m1 '\\contactphone' || true)"
  phone_digits="$(printf '%s' "$phone_line" | sed 's/.*\\contactphone//' | tr -cd '0-9')"
  if [[ ${#phone_digits} -lt 8 ]]; then
    warn "phone.tex has no phone-like digit run; skipping phone-number scan"
    phone_digits=""
  fi
else
  ok "no phone.tex in the source tree; nothing to compare against"
fi

# ---- 3. the public PDF must not contain the phone number ------------------
if [[ -n "$phone_digits" ]]; then
  # raw bytes: catches uncompressed/info strings
  if grep -qaF -- "$phone_digits" "$PDF"; then
    fail "public PDF raw bytes contain the private phone number (redacted)"
  fi

  if command -v pdftotext >/dev/null 2>&1; then
    pdf_text="$(pdftotext "$PDF" - 2>/dev/null || true)"
    pdf_digits="$(printf '%s' "$pdf_text" | tr -cd '0-9')"
    if [[ "$pdf_digits" == *"$phone_digits"* ]]; then
      fail "public PDF text contains the private phone number (redacted)"
    fi
    ok "public PDF text does not contain the private phone number (${#phone_digits} digits checked, redacted)"
  else
    warn "pdftotext not installed; skipped PDF text scan (raw-byte scan still ran)"
  fi

  # ---- 4. build logs must not contain it either ---------------------------
  for log in "$ROOT"/resume-public.log "$ROOT"/resume.log; do
    [[ -f "$log" ]] || continue
    log_digits="$(tr -cd '0-9' <"$log")"
    if [[ "$log_digits" == *"$phone_digits"* ]]; then
      fail "build log $(basename "$log") contains the private phone number (redacted)"
    fi
    ok "build log $(basename "$log") is clean"
  done
fi

ok "public build carries no private inputs"
