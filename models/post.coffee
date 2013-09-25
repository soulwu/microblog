mongodb = require './db'

class Post
  constructor: (@user, @post, @time = new Date()) ->

  save: (callback) ->
    post =
      user: @user
      post: @post
      time: @time

    mongodb.open (err, db) ->
      return callback err if err

      db.collection 'posts', (err, collection) ->
        if err
          mongodb.close()
          return callback err

        collection.ensureIndex 'user'
        collection.insert post, safe: true, (err, post) ->
          mongodb.close()
          callback err, post

  @get = (user, callback) ->
    mongodb.open (err, db) ->
      return callback err if err

      db.collection 'posts', (err, collection) ->
        if err
          mongodb.close()
          return callback err

        query = {}
        query.user = user if user

        collection.find(query).sort(time: -1).toArray (err, docs) ->
          mongodb.close()
          return callback err, null if err

          posts = (new Post doc.user, doc.post, doc.time for doc in docs)
          callback null, posts

module.exports = Post