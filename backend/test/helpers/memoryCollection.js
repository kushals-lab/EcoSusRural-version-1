'use strict';

// A deterministic collection double; never connects to a production database.
function memoryCollection() {
  const documents = new Map();
  const indexes = [];
  function matches(document, filter) {
    return Object.entries(filter).every(([key, expected]) => {
      const value = document[key];
      if (expected && typeof expected === 'object' && !(expected instanceof Date)) {
        return Object.entries(expected).every(([operator, limit]) => {
          if (operator === '$lt') return value < limit;
          if (operator === '$lte') return value <= limit;
          if (operator === '$gt') return value > limit;
          throw new Error(`Unsupported test operator: ${operator}`);
        });
      }
      return value === expected;
    });
  }
  function update(filter, change, options = {}) {
    const entry = [...documents.entries()].find(([, document]) => matches(document, filter));
    let document = entry?.[1];
    const id = filter._id ?? filter.id;
    if (!document && !options.upsert) return null;
    if (!document) {
      if (documents.has(id)) throw Object.assign(new Error('duplicate'), { code: 11000 });
      document = { ...(filter._id ? { _id: id } : { id }), ...change.$setOnInsert };
    }
    Object.assign(document, change.$set);
    for (const [key, increment] of Object.entries(change.$inc || {})) document[key] = (document[key] || 0) + increment;
    for (const key of Object.keys(change.$unset || {})) delete document[key];
    documents.set(entry?.[0] ?? id, document);
    return structuredClone(document);
  }
  return {
    documents, indexes,
    createIndex: async (...args) => { indexes.push(args); return 'test_index'; },
    findOne: async (filter) => structuredClone([...documents.values()].find((document) => matches(document, filter)) || null),
    findOneAndUpdate: async (...args) => update(...args),
    updateOne: async (...args) => ({ modifiedCount: update(...args) ? 1 : 0 }),
    deleteOne: async (filter) => {
      const entry = [...documents.entries()].find(([, document]) => matches(document, filter));
      if (entry) documents.delete(entry[0]);
      return { deletedCount: entry ? 1 : 0 };
    },
  };
}

module.exports = { memoryCollection };
