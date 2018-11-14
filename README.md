# ZmqEx
[![CircleCI](https://circleci.com/gh/half-t/zmq_ex.svg?style=svg)](https://circleci.com/gh/half-t/zmq_ex)
[![Coverage Status](https://coveralls.io/repos/github/half-t/zmq_ex/badge.svg?branch=master)](https://coveralls.io/github/half-t/zmq_ex?branch=master)

## About
ZmqEx - 100% native Elixir implementation of ZMTP protocol

## Note
Note that at this stage it's a *learning field* aiming to deliver production ready library in the future

## Installation

The package can be installed by adding `zmq_ex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:zmq_ex, "~> 0.0.1"}
  ]
end
```

## Documentation

```
mix docs
Docs successfully generated.
View them at "doc/index.html".
```

Online documentation can be found at [https://hexdocs.pm/zmq_ex](https://hexdocs.pm/zmq_ex).

## Test

```
mix test
```

> Note: credo and formatter are added to test run

## Additional tools

* Credo: `mix credo --strict` - a static code analysis tool for Elixir
* Dialyzer: `mix dialyzer` - a type checker
* Formatter: `mix format --check-formatted` - build in elixir formatter

## python enV

```
virtualenv -p python3 ./py
. ./py/bin/activate
pip install pyzmq
python ./python_server.py
```

