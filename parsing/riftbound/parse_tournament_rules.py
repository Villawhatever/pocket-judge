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
parser.add_argument('-d', '--dry', help='should this be a test run or not?', type=bool, default=True)

args = parser.parse_args()
filename = 'tournament-rules.txt'
with open(filename, 'r', encoding='utf8') as f:
    data = f.read()
    lines = data.split('\n')
    pattern = r'(\d+(?:\.(?:\d+)?\.?(?:\w+)?){0,5}) (.+)$'
    matches = re.findall(pattern, data, flags=re.MULTILINE)

    for match in matches:
        number = match[0]
        text = match[1]

        if (args.dry):
            print(f'{number}: {text}')
        else:
            rule = {
                'ruleNumber': number,
                'text': text.replace('”', '"')
            }
            rulesRef.document(number).set(rule)

    if (args.dry):
        print('==========')
        print(f'Found {len(matches)} rules')
