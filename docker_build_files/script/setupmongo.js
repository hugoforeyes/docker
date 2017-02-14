use admin
db.createUser(
  {
    user: "root",
    pwd: "123456",
    roles: [ { role: "userAdminAnyDatabase", db: "admin" } ]
  }
)

use streameddb
db.getCollection('t_journal_external').createIndex( { "user_id": 1, 'summary_search' : 1 } )
db.getCollection('t_journal_external').createIndex( { "user_id": 1, 'summary_search' : 1, 'category' : 1, 'credit_category' : 1, 'amount' : 1, 'issue_date' : 1 } )


db.createUser(
  {
    user: "streameddb",
    pwd: "8ry7vpb(KVyiadmrpnbh",
    roles: [ { role: "readWrite", db: "streameddb" } ]
  }
)
