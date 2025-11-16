#!/usr/bin/env node

const [, , password] = process.argv;

if (password === undefined) {
  console.error('Usage: node scripts/urlencode_password.mjs <password>');
  process.exit(1);
}

console.log(encodeURIComponent(password));
