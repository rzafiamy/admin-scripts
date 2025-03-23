#!/bin/bash

CERT_DIR="/opt/proxymanager/letsencrypt/archive"

# Header
printf "\n%-60s │ %-30s │ %-40s │ %-25s\n" "📄 Full Path" "🌐 Site Name (CN)" "🛰️  SANs" "📅 Expiration Date"
printf '%.0s─' {1..170}
echo

# Search cert*.pem recursively
find "$CERT_DIR" -type f -name 'cert*.pem' | while read -r cert; do

    # Full path
    full_path="$cert"

    # Subject (CN)
    subject=$(openssl x509 -in "$cert" -noout -subject 2>/dev/null | sed -n 's/.*CN = //p')

    # SANs (trim + format)
    sans=$(openssl x509 -in "$cert" -noout -text 2>/dev/null | \
        awk '/X509v3 Subject Alternative Name/ {getline; print}' | \
        sed 's/DNS://g' | tr -d '\n' | cut -c1-40)

    # Expiration date
    end_date=$(openssl x509 -in "$cert" -noout -enddate 2>/dev/null | cut -d= -f2)

    # Print row if valid
    if [[ -n "$subject" && -n "$end_date" ]]; then
        printf "%-60s │ %-30s │ %-40s │ %-25s\n" "$full_path" "$subject" "$sans" "$end_date"
    fi
done
