## Forms Cli ##

The forms cli includes commands for common support tasks.


### Installation ###

Run `bundle install` and add the `./bin/forms` bash script to your shells `PATH` variable.

### Usage ###

For a list of available commands type `forms`. Each command includes a help command. For further information type `forms <command> --help`.

### AWS Authentication ###

Any command that requires authorisation to make AWS api calls will need to be run in an authorised shell. This can be done with the `gds-cli` or `aws-vault`. Each command includes instructions where necessary. For example:

`gds aws forms-dev-support -- forms ecs_summary`

### Updating the cli ###

Raise a PR for any changes and ask in govuk-forms-tech for a review. Github actions runs `rspec` and `rubocop` on each PR.
