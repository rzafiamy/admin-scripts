import subprocess
import re
import argparse
from datetime import datetime

# Emoji for statuses
BOUNCE_EMOJI = "🚫"

# Regex patterns
RSYSLOG_REGEX = re.compile(r'(\w{3}\s+\d+\s[\d:]+).*?postfix.*?to=<([^>]+)>.*?status=bounced.*?\((.*?)\)')
SYSTEMD_REGEX = re.compile(r'^([\d-]+ [\d:]+).*postfix.*to=<([^>]+)>.*status=bounced.*\((.*?)\)')
MAILQ_REGEX = re.compile(r'(\w+)\*?\s+(\w{3}\s+\w{3}\s+\d+\s+[\d:]+)\s+(\S+).*\n\s*\((.*?)\)')


def parse_rsyslog():
    bounced_emails = []
    with open("/var/log/mail.log", 'r') as f:
        for line in f:
            match = RSYSLOG_REGEX.search(line)
            if match:
                date_str, recipient, reason = match.groups()
                date = datetime.strptime(date_str, "%b %d %H:%M:%S")
                bounced_emails.append((None, date, recipient, reason))
    return bounced_emails


def parse_systemd():
    bounced_emails = []
    result = subprocess.run(['journalctl', '-u', 'postfix@-.service', '--no-pager', '-o', 'short-iso'], stdout=subprocess.PIPE, text=True)
    log_lines = result.stdout.splitlines()
    for line in log_lines:
        match = SYSTEMD_REGEX.search(line)
        if match:
            date_str, recipient, reason = match.groups()
            date = datetime.strptime(date_str, "%Y-%m-%d %H:%M:%S")
            bounced_emails.append((None, date, recipient, reason))
    return bounced_emails


def parse_mailq():
    bounced_emails = []
    result = subprocess.run(['postqueue', '-p'], stdout=subprocess.PIPE, text=True)
    queue_output = result.stdout
    matches = MAILQ_REGEX.findall(queue_output)
    for msg_id, date_str, recipient, reason in matches:
        try:
            date = datetime.strptime(date_str, "%a %b %d %H:%M:%S")
        except ValueError:
            date = datetime.now()
        bounced_emails.append((msg_id, date, recipient, reason))
    return bounced_emails


def display_table(bounced_emails):
    print(f"\n{'📧 Postfix Bounced Email Monitor 📧':^100}")
    print("=" * 100)
    print(f"{'Message ID':<15} | {'Date & Time':<20} | {'Recipient':<35} | {'Reason'}")
    print("-" * 100)

    for msg_id, date, recipient, reason in bounced_emails:
        date_str = date.strftime("%Y-%m-%d %H:%M")
        msg_display = msg_id if msg_id else "-"
        print(f"{BOUNCE_EMOJI} {msg_display:<12} | {date_str:<17} | {recipient:<35} | {reason}")

    print("=" * 100)
    print(f"Total Bounced Emails: {len(bounced_emails)}")


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Monitor Postfix bounced emails.")
    parser.add_argument('--mode', choices=['rsyslog', 'systemd', 'mailq'], required=True, help='Log source to parse')
    args = parser.parse_args()

    if args.mode == 'rsyslog':
        bounced_emails = parse_rsyslog()
    elif args.mode == 'systemd':
        bounced_emails = parse_systemd()
    elif args.mode == 'mailq':
        bounced_emails = parse_mailq()

    if bounced_emails:
        display_table(bounced_emails)
    else:
        print("✅ No bounced emails found!")