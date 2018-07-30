# subastas-automaticas-iasc
Repositorio para el trabajo práctico de subastas autómaticas de la materia electiva Implementación de Arquitecturas de Software Concurrente.

## levantar la API
  dentro de la carpeta api rest

    iex --name api@[IP] -S mix


## levantar el balancer
  dentro de la carpeta balancer

    iex --name balancer@[IP] -S mix

    LoadBalancer.Supervisor.start_link (para arrancar el balancer)
    Syncronizer.Supervisor.start_link (para arrancar el syncronizer)
## levantar workers
  dentro de la carpeta worker

    iex --name worker-[nombre]-[numero]@[IP] -S mix

    InitWorker.start_worker (para iniciar el worker)

## para conectar los nodos (la conectividad es transitiva, si conectas a uno con los demas el resto se conocen entre ellos)

    Node.ping :"[nombre del nodo]"

## Para correr con docker crear las imagenes y levantar con compose

```
docker build -t worker worker/
docker build -t balancer balancer/
docker build -t api ApiRest/

docker stack deploy -c docker-compose.yml auction
```
