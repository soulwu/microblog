crypto = require 'crypto'
User = require '../models/user'

module.exports = (app) ->
  app.get '/', (req, res) ->
    res.render 'index', title: '首页'

  app.get '/reg', (req, res) ->
    res.render 'reg', title: '用户注册'

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