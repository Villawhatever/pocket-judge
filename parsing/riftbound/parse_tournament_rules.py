import argparse
import firebase_admin
from firebase_admin import credentials
from google.cloud import firestore
import json
import re

cred = credentials.Certificate('firebase-key.json')
firebase_admin.initialize_app(cred)

db = firestore.Client()
rulesRef = db.collection('tournament_rules')

parser = argparse.ArgumentParser()
parser.add_argument('-r', '--real', help='should this be a real run or not?', action='store_true')

args = parser.parse_args()
filename = 'tournament-rules.txt'
with open(filename, 'r', encoding='utf8') as f:
    data = f.read()
    lines = data.split('\n')
    pattern = r'^(\d+(?:\.(?:\d+)?\.?(?:\w+)?){0,5}) (.+)$'
    matches = re.findall(pattern, data, flags=re.MULTILINE)
    existing = []

    for match in matches:
        number = match[0]
        text = match[1]

        if (not args.real):
            print(f'{number}: {text}\n')
        else:
            rule = {
                'ruleNumber': number,
                'text': text.replace('”', '"')
            }
            rulesRef.document(number).set(rule)

        print(f'added {number}')
        existing.append(number)

    for doc in rulesRef.stream():
            if doc.get('ruleNumber') not in existing:
                if (not args.real):
                    print(f'{doc.get('ruleNumber')} does not exist in new doc')
                else:
                    print(f'Deleting stale rule {doc.get('ruleNumber')}')
                    rulesRef.document(doc.get('ruleNumber')).delete()

    if (not args.real):
        print('==========')
        print(f'Found {len(matches)} rules')
