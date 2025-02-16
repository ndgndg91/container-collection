db = db.getSiblingDB('notification');

db.createUser({
    user: "appuser",
    pwd: "apppassword",
    roles: [{ role: "readWrite", db: "notification" }]
});

db.createCollection('notification_sends');
db.notification_sends.createIndex({ created_at: -1 }, {name: 'notification_sends_created_at_desc_idx'} );
db.notification_sends.createIndex({ created_at: 1 },{ expireAfterSeconds: 2592000 }, {name: 'notification_sends_created_at_30days_ttl_idx'}); // 30일(30 * 24 * 60 * 60)
db.notification_sends.createIndex({ account_id: 1, category: 1, subcategory: 1, created_at: -1 }, {name: 'notification_sends_account_id_category_subcategory_created_at_idx'});