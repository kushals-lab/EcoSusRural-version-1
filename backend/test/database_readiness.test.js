'use strict';

const { test } = require('node:test');
const assert = require('node:assert/strict');
const { Pool } = require('pg');

test('database readiness uses a read-only query and tracks recovery', async () => {
  const originalQuery = Pool.prototype.query;
  let calls = [];
  try {
    Pool.prototype.query = async (sql) => {
      calls.push(sql);
      return { rows: [{ '?column?': 1 }] };
    };
    const db = require('../src/db/postgres');
    assert.equal(await db.checkDatabase(), true);
    assert.equal(db.isDbConnected(), true);
    assert.deepEqual(calls, ['SELECT 1']);

    Pool.prototype.query = async (sql) => {
      calls.push(sql);
      throw new Error('synthetic connection failure');
    };
    assert.equal(await db.checkDatabase(), false);
    assert.equal(db.isDbConnected(), false);
    assert.deepEqual(calls, ['SELECT 1', 'SELECT 1']);
  } finally {
    Pool.prototype.query = originalQuery;
  }
});
