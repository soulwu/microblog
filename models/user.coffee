mongodb = require './db'

class User
  constructor: (user) ->
    @name = user.name
    @password = user.password

  save: (callback) ->
    user =
      name: @name
      password: @password

    mongodb.open (err, db) ->
      return callback err if err

      db.collection 'users', (err, collection) ->
        if err
          mongodb.close()
          return callback err

        collection.ensureIndex 'name', unique: true
        collection.insert user, safe: true, (err, user) ->
          mongodb.close()
          callback err, user

  @get = (username, callback) ->
    mongodb.open (err, db) ->
      return callback err if err

      db.collection 'users', (err, collection) ->
        if err
          mongodb.close()
          return callback err

        collection.findOne name: username, (err, doc) ->
          mongodb.close()
          if doc then callback err, new User doc else callback err, null

module.exports = User