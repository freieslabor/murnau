[![build status](https://gitlab.com/freieslabor/murnau/badges/master/build.svg)](https://gitlab.com/freieslabor/murnau/commits/master)
[![Inline docs](http://inch-ci.org/github/freieslabor/murnau.svg?branch=master)](http://inch-ci.org/github/freieslabor/murnau)
[![travis-ci](https://travis-ci.org/freieslabor/murnau.svg?branch=master)](https://travis-ci.org/freieslabor/murnau)
[![Coverage Status](https://coveralls.io/repos/github/freieslabor/murnau/badge.svg?branch=master)](https://coveralls.io/github/freieslabor/murnau?branch=master)
[![Deps Status](https://beta.hexfaktor.org/badge/all/github/freieslabor/murnau.svg)](https://beta.hexfaktor.org/github/freieslabor/murnau)

# Murnau

A Bot for the freieslabor.org infrastructure.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add murnau to your list of dependencies in `mix.exs`:

        def deps do
          [{:murnau, "~> 0.0.1"}]
        end

  2. Ensure murnau is started before your application:

        def application do
          [applications: [:murnau]]
        end

