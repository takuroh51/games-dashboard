#!/usr/bin/env node
/**
 * パスワードハッシュ生成ツール
 * 使い方: node scripts/generate-password-hash.js <password>
 */

const crypto = require('crypto');

const password = process.argv[2];

if (!password) {
  console.error('使い方: node scripts/generate-password-hash.js <password>');
  console.error('例: node scripts/generate-password-hash.js skoota2025');
  process.exit(1);
}

const hash = crypto.createHash('sha256').update(password).digest('hex');

console.log('');
console.log('='.repeat(60));
console.log('パスワードハッシュ生成完了');
console.log('='.repeat(60));
console.log('');
console.log(`パスワード: ${password}`);
console.log(`SHA-256ハッシュ: ${hash}`);
console.log('');
console.log('このハッシュを frontend/src/utils/auth.ts の');
console.log('DEFAULT_PASSWORD_HASH に設定してください。');
console.log('');
console.log('または、環境変数として設定：');
console.log(`NEXT_PUBLIC_PASSWORD_HASH=${hash}`);
console.log('');
