#!/usr/bin/env python3

import os
import subprocess
import argparse
from collections import defaultdict
from rich.console import Console
from rich.table import Table

MAIL_FOLDERS = ['cur', 'new', 'tmp']
SPECIAL_FOLDERS = {
    'Sent': ['.Sent'],
    'Drafts': ['.Drafts'],
    'Trash': ['.Trash'],
    'Junk': ['.Junk']
}

def get_disk_usage(path):
    try:
        result = subprocess.run(['du', '-sh', path], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, check=True)
        return result.stdout.split()[0]
    except subprocess.CalledProcessError:
        return '0B'

def count_mails(maildir):
    mail_stats = defaultdict(int)
    for folder in MAIL_FOLDERS:
        folder_path = os.path.join(maildir, folder)
        if os.path.exists(folder_path):
            mail_stats[folder] = sum(len(files) for _, _, files in os.walk(folder_path))

    for name, paths in SPECIAL_FOLDERS.items():
        for folder in paths:
            folder_path = os.path.join(maildir, folder)
            if os.path.exists(folder_path):
                mail_stats[name] += sum(len(files) for _, _, files in os.walk(folder_path))

    return mail_stats

def analyze_domains(base_path):
    domains = [domain for domain in os.listdir(base_path) if os.path.isdir(os.path.join(base_path, domain))]
    stats = {}
    for domain in domains:
        domain_path = os.path.join(base_path, domain)
        users = [user for user in os.listdir(domain_path) if os.path.isdir(os.path.join(domain_path, user))]
        for user in users:
            user_path = os.path.join(domain_path, user)
            disk_usage = get_disk_usage(user_path)
            mail_stats = count_mails(user_path)
            stats[f"{user}@{domain}"] = {'disk_usage': disk_usage, 'mail_stats': mail_stats}
    return stats

def print_stats(stats):
    console = Console()
    table = Table(title="📊 Mail Quota and Stats")

    table.add_column("👤 User", style="bold cyan")
    table.add_column("💾 Disk Usage", justify="right")
    table.add_column("📬 Inbox", justify="right")
    table.add_column("📤 Sent", justify="right")
    table.add_column("📝 Drafts", justify="right")
    table.add_column("🗑️ Trash", justify="right")
    table.add_column("📁 Junk", justify="right")

    for user, info in stats.items():
        mail = info['mail_stats']
        inbox_count = mail.get('cur', 0) + mail.get('new', 0)
        table.add_row(
            user,
            info['disk_usage'],
            str(inbox_count),
            str(mail.get('Sent', 0)),
            str(mail.get('Drafts', 0)),
            str(mail.get('Trash', 0)),
            str(mail.get('Junk', 0))
        )

    console.print(table)

def main():
    parser = argparse.ArgumentParser(description='Analyze disk quotas and mail stats for domain users.')
    parser.add_argument('path', help='Path to the domain maildir directory.')
    args = parser.parse_args()

    if not os.path.exists(args.path):
        print("❌ Provided path does not exist.")
        exit(1)

    stats = analyze_domains(args.path)
    print_stats(stats)

if __name__ == "__main__":
    main()



