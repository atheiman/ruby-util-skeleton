# Ruby Util Skeleton

> TODO:
>
> 1. add `-c, --config <config>` flag for config.rb

This repo is a skeleton for a simple ruby utility.

Download:

```shell
curl https://github.com/atheiman/ruby-util-skeleton/archive/master.tar.gz | tar xvz
mv ruby-util-skeleton my-util-project
```

## Basic Startup

This is pretty open-ended, but a straight-forward usage would be:

`config.rb` contains config for the util that should be updated per situation (url to use for an api, for example), `defaults.rb` should only change when code changes.

`items.json` contains the json that your util uses (if needed).

`util.rb` is the utility (make your call to the api, for example).

Use the util:

```shell
ruby util.rb
```
