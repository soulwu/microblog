cluster = require 'cluster'
os = require 'os'

numCPUs = os.cpus().length

workers = {}
if cluster.isMaster
  for i in [0...numCPUs]
    worker = cluster.fork()
    workers[worker.pid] = worker
  cluster.on 'exit', (worker) ->
    delete workers[worker.pid]
    worker = cluster.fork()
    workers[worker.pid] = worker
else
  app = require './app'
  app.listen app.get('port')

process.on 'SIGTERM', ->
  process.kill pid for pid of workers
  process.exit 0