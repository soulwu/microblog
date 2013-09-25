crypto = require 'crypto'
User = require '../models/user'
Post = require '../models/post'

module.exports = (app) ->
  app.get '/', (req, res) ->
    Post.get null, (err, posts) ->
      posts = [] if err
      res.render 'index',
        title: '首页'
        posts: posts

  app.get '/reg', checkNotLogin
  app.get '/reg', (req, res) ->
    res.render 'reg', title: '用户注册'

  app.post '/reg', checkNotLogin
  app.post '/reg', (req, res) ->
    if req.body['password-repeat'] isnt req.body['password']
      req.flash 'error', '两次输入的口令不一致'
      return res.redirect '/reg'
    md5 = crypto.createHash 'md5'
    password = md5.update(req.body.password).digest 'base64'
    newUser = new User
      name: req.body.username
      password: password
    User.get newUser.name, (err, user) ->
      err = 'Username already exists.' if user
      if err
        req.flash 'error', err
        return res.redirect '/reg'
      newUser.save (err) ->
        if err
          req.flash 'error', err
          return res.redirect '/reg'
        req.session.user = newUser
        req.flash 'success', '注册成功'
        res.redirect '/'

  app.get '/login', checkNotLogin
  app.get '/login', (req, res) -> res.render 'login', title: '用户登入'

  app.post '/login', checkNotLogin
  app.post '/login', (req, res) ->
    md5 = crypto.createHash 'md5'
    password = md5.update(req.body.password).digest 'base64'

    User.get req.body.username, (err, user) ->
      unless user
        req.flash 'error', '用户不存在'
        return res.redirect '/login'

      if user.password isnt password
        req.flash 'error', '用户口令错误'
        return res.redirect '/login'

      req.session.user = user
      req.flash 'success', '登入成功'
      res.redirect '/'

  app.get '/logout', checkLogin
  app.get '/logout', (req, res) ->
    req.session.user = null
    req.flash 'success', '登出成功'
    res.redirect '/'

  app.post '/post', checkLogin
  app.post '/post', (req, res) ->
    currentUser = req.session.user
    post = new Post currentUser.name, req.body.post
    post.save (err) ->
      if err
        req.flash 'error', err
        return res.redirect '/'
      req.flash 'success', '发表成功'
      res.redirect "/u/#{currentUser.name}"

  app.get '/u/:user', (req, res) ->
    User.get req.params.user, (err, user) ->
      unless user
        req.flash 'error', '用户不存在'
        return res.redirect '/'
      Post.get user.name, (err, posts) ->
        if err
          req.flash 'error', err
          return res.redirect '/'
        res.render 'user',
          title: user.name
          posts: posts

checkLogin = (req, res, next) ->
  unless req.session.user
    req.flash 'error', '未登入'
    return res.redirect '/login'
  next()

checkNotLogin = (req, res, next) ->
  if req.session.user
    req.flash 'error', '已登入'
    return res.redirect '/'
  next()