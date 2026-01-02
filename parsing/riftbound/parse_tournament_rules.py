import json
import re

class Rule:
    def __init__(self, number, text):
        self.number = number
        self.text = text

    def to_dict(self):
        return {'number': self.number, 'text': self.text}

pattern = r'(\d+(?:\.(?:\d+)?\.?(?:\w+)?){0,5}) (.+)$'
filename = 'riftbound-tournament-rules.txt'

rules = []

with open(filename, 'r', encoding='utf8') as f:
    data = f.read()
    lines = data.split('\n')
    matches = re.findall(pattern, data, flags=re.MULTILINE)
    for match in matches:
        ruleNumber = match[0]
        text = match[1]
        rule = Rule(ruleNumber, text)
        rules.append(rule)

with open('../../lib/assets/riftbound_tournament_rules.json', 'w') as out:
    json.dump([x.to_dict() for x in rules], out)