path = r'c:\Users\user\OneDrive\Microsoft Copilot Chat Files\Desktop\EcoSusRural\eco_sus_rural\backend\smoke_test.mjs'
src = open(path, encoding='utf-8').read()
bad = """main().catch((e) => {
  console.error(e);
  process.exit(1);
});
main().catch((e) => {
  console.error(e);
  process.exit(1);
});
// --- end of file: run with `node smoke_test.js` (backend running) ---
"""
good = """main().catch((e) => {
  console.error(e);
  process.exit(1);
});
// --- end of file: run with `node smoke_test.js` (backend running) ---
"""
if bad in src:
    open(path, 'w', encoding='utf-8').write(src.replace(bad, good))
    print('replaced')
else:
    print('NOT FOUND')
    print('---tail---')
    print(src[-400:])