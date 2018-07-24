{application,confex,
             [{description,"Helper module that provides a nice way to read configuration at runtime from environment variables or\nvia adapter-supported interface.\n"},
              {modules,['Elixir.Confex','Elixir.Confex.Adapter',
                        'Elixir.Confex.Adapters.FileFromSystemEnvironment',
                        'Elixir.Confex.Adapters.SystemEnvironment',
                        'Elixir.Confex.Resolver','Elixir.Confex.Type']},
              {registered,[]},
              {vsn,"3.3.1"},
              {applications,[kernel,stdlib,elixir]}]}.
