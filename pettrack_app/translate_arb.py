import json
from deep_translator import GoogleTranslator

def main():
    with open('lib/l10n/app_en.arb', 'r', encoding='utf-8') as f:
        en_data = json.load(f)
    
    langs = {'zh': 'zh-CN', 'it': 'it', 'de': 'de', 'ja': 'ja', 'ko': 'ko'}
    
    keys = []
    values = []
    for k, v in en_data.items():
        if not k.startswith('@'):
            keys.append(k)
            values.append(v)
            
    for lang_code, trans_code in langs.items():
        print(f"Translating {lang_code}...")
        translator = GoogleTranslator(source='en', target=trans_code)
        
        # Batch translation
        translated_values = translator.translate_batch(values)
        
        out_data = {"@@locale": lang_code}
        for k, v in en_data.items():
            if k.startswith('@'):
                if k == '@@locale':
                    continue
                out_data[k] = v
        
        for k, trans_v in zip(keys, translated_values):
            if trans_v:
                # Basic fix for placeholders
                trans_v = trans_v.replace('{ ', '{').replace(' }', '}').replace('  ', ' ')
                out_data[k] = trans_v
            else:
                out_data[k] = en_data[k]
                
        with open(f'lib/l10n/app_{lang_code}.arb', 'w', encoding='utf-8') as f:
            json.dump(out_data, f, ensure_ascii=False, indent=2)

if __name__ == '__main__':
    main()
