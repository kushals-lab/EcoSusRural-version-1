// Read the public signing certificate from an Android APK's v2/v3 signature.
// Usage: node scripts/apk-signing-certificate.cjs path/to/application.apk
'use strict';

const fs = require('node:fs');
const { X509Certificate } = require('node:crypto');

const apkPath = process.argv[2];
if (!apkPath) throw new Error('Provide an APK path.');
const apk = fs.readFileSync(apkPath);
let eocd = -1;
for (let offset = apk.length - 22; offset >= Math.max(0, apk.length - 65557); offset--) {
  if (apk.readUInt32LE(offset) === 0x06054b50 &&
      offset + 22 + apk.readUInt16LE(offset + 20) === apk.length) {
    eocd = offset;
    break;
  }
}
if (eocd < 0) throw new Error('ZIP end record not found.');
const directoryOffset = apk.readUInt32LE(eocd + 16);
if (apk.subarray(directoryOffset - 16, directoryOffset).toString() !== 'APK Sig Block 42') {
  throw new Error('APK v2/v3 signing block not found.');
}
const blockSize = Number(apk.readBigUInt64LE(directoryOffset - 24));
const blockStart = directoryOffset - blockSize - 8;
if (blockStart < 0 || Number(apk.readBigUInt64LE(blockStart)) !== blockSize) {
  throw new Error('Invalid APK signing block size.');
}
function field(buffer, offset = 0) {
  if (offset + 4 > buffer.length) throw new Error('Truncated signing field.');
  const end = offset + 4 + buffer.readUInt32LE(offset);
  if (end > buffer.length) throw new Error('Invalid signing field length.');
  return { bytes: buffer.subarray(offset + 4, end), end };
}
const seen = new Set();
for (let offset = blockStart + 8; offset < directoryOffset - 24;) {
  const pairSize = Number(apk.readBigUInt64LE(offset));
  const pairEnd = offset + 8 + pairSize;
  if (pairSize < 4 || pairEnd > directoryOffset - 24) throw new Error('Invalid signature entry.');
  const id = apk.readUInt32LE(offset + 8);
  if ([0x7109871a, 0xf05368c0, 0x1b93ad61].includes(id)) {
    const signers = field(apk.subarray(offset + 12, pairEnd)).bytes;
    for (let signerOffset = 0; signerOffset < signers.length;) {
      const signer = field(signers, signerOffset);
      const signedData = field(signer.bytes).bytes;
      const digests = field(signedData);
      const certificates = field(signedData, digests.end).bytes;
      const certificate = new X509Certificate(field(certificates).bytes);
      if (!seen.has(certificate.fingerprint256)) {
        seen.add(certificate.fingerprint256);
        console.log(`Subject: ${certificate.subject}`);
        console.log(`SHA-1: ${certificate.fingerprint}`);
        console.log(`SHA-256: ${certificate.fingerprint256}`);
        console.log(`Valid until: ${certificate.validTo}`);
      }
      signerOffset = signer.end;
    }
  }
  offset = pairEnd;
}
if (!seen.size) throw new Error('No supported APK signer certificate found.');
