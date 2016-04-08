Client to asynchronously collect db data and send to Suchfast for analysis.

## Requirements

If you are using Postgres, this gem requires Postgres extension: pg_stat_statemnts. You already have it if you are on Heroku.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'suchfast'
```

## Configuration

There are two main considerations for configuration:

### Asynchronous Job Setup

If you already have an asynchronous library in use, then create a job which runs the following:

`Suchfast::DataExporter.export`

and in your configuration, make sure to set `gem_runs_job: false`

### Scheduling

If you already have a scheduling mechanism set up (cron, clockwork, etc...), then call the job you set up in previous step. 

We recommend calling the job every three hours.

In your configuration, make sure to set `gem_schedules_job: false`

## How It Works

Captures all or part of the following tables:

0. pg_stat_statements. Entire table.
0. pg_class. Part. Only table size.
0. pg_stats. Part. Only uploads cardinality.
0. pg_indexes. Entire table. For indexes.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/suchfast/suchfast.

## License

The gem is Copyright 2016 Suchfast, Inc.

[activejob]: http://edgeguides.rubyonrails.org/active_job_basics.html

