{application,distributed,
             [{applications,[kernel,stdlib,elixir,logger]},
              {description,"distributed"},
              {modules,['Elixir.LoadBalancer',
                        'Elixir.LoadBalancer.Supervisor','Elixir.Pid',
                        'Elixir.Syncronizer','Elixir.Syncronizer.Supervisor',
                        'Elixir.WorkerUtils']},
              {registered,[]},
              {vsn,"0.1.0"},
              {extra_applications,[logger]}]}.