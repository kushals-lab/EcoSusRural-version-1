path = r'c:\Users\user\OneDrive\Microsoft Copilot Chat Files\Desktop\EcoSusRural\eco_sus_rural\backend\smoke_test.mjs'
raw = open(path, 'rb').read()
# Keep everything through the FIRST main().catch's closer (line 96's })),
# and DELETE the duplicate from the second main().catch onwards.
idx = raw.rfind(b"main().catch((e) => {")
if idx == -1:
    print('ANCHOR NOT FOUND')
else:
    print('anchor at', idx)
    out = raw[:idx]
    open(path, 'wb').write(out)
    print('written', len(out), 'bytes')