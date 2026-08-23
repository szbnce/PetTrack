import json

with open('lib/l10n/app_en.arb', 'r', encoding='utf-8') as f:
    data = json.load(f)

langs = ['zh', 'it', 'de', 'ja', 'ko']
for lang in langs:
    data["@@locale"] = lang
    with open(f'lib/l10n/app_{lang}.arb', 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
