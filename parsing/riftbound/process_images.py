from pathlib import Path
from PIL import Image

import json
import requests
import time

filename = '../../lib/assets/cards.json'
start = time.perf_counter()

with open(filename, 'r', encoding='utf8') as f:
    cards = json.load(f)

    for card in cards:
        set = card['id'].split('-')[0]
        path = f'../../lib/assets/cards/{set}'
        Path(path).mkdir(parents=True, exist_ok=True)

        cardLocation = f'{path}/{card['id']}.webp'
        if not Path(f'{path}/{card['id']}.webp').exists():
            print(f'processing {card['id']}')
            image = Image.open(requests.get(card['image_url'], stream=True).raw)
            image.save(f'{path}/{card['id']}.webp', 'webp')
        else:
            print(f'Already have {card['id']}. Skipping...')
    end = time.perf_counter()
    print(f'Processed {len(cards)} cards in {end-start:.2f} seconds')