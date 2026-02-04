import firebase_admin
from firebase_admin import credentials
from google.cloud import firestore
import json
import re

pattern = r'(\d+(?:\.(?:\d+)?\.?(?:\w+)?){0,5}) (.+)$'

rules = []

cred = credentials.Certificate('firebase-key.json')

firebase_admin.initialize_app(cred)

db = firestore.Client()
rulesRef = db.collection('tournament_rules')

filename = 'tournament-rules.txt'
with open(filename, 'r', encoding='utf8') as f:
    data = f.read()
    lines = data.split('\n')
    matches = re.findall(pattern, data, flags=re.MULTILINE)
    for match in matches:
        number = match[0]
        text = match[1]
        rule = {
            'ruleNumber': number,
            'text': text
        }
        rulesRef.document(number).set(rule)
