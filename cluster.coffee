cluster = require 'cluster'
os = require 'os'

numCPUs = os.cpus().length

if cluster.isMaster
  for i in [0...numCPUs]
    cluster.fork()
  cluster.on 'exit', (worker) ->
    cluster.fork()
  process.on 'SIGTERM', ->
    cluster.workers[id].kill() for id of cluster.workers
else if cluster.isWorker
  app = require './app'
  app.listen app.get('port')