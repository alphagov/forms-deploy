# Deploy Account Updater

## Purpose

The main purpose of `/lib/terraform_checker.rb` is to automate running `terraform plan` on the roots in the `deploy` directory and notify an SRE of which roots need further investigation.

The other purpose was for me to practice writing Ruby during Fire Break.

## Context

Every week the Infra team has to iterate through the `deploy` directory running `make deploy deploy/<root> plan` to ensure the deploy account is up-to-date. 

This is a side effect of the deploy account not having its own CI/CD pipeline like the other accounts. Occasionally code will be merged but not deployed, causing drift between whats in AWS and what's in our Terraform. 

The Infra team decided that since we don't make changes to the deploy account frequently a weekly reminder to check for drift was sufficient.

Most of the time running `make deploy deploy/<root> plan` results in a `No changes` output from Terraform, but from time to time we'll discover drift, need to investigate, and run `make deploy deploy/<root> apply` to absorb the changes.

It is slightly tedious to have to run `make deploy deploy/<root> plan` multiple times only to confirm that there are no changes.

One approach to fix the tedium would be to adjust the `invoke-terraform.sh` script to accept multiple roots.

I considered this, but I really wanted to practice writing Ruby. 

So I decided to write a Ruby script which would alleviate the tedium and notify me of any roots which need further attention.

The goal is to run the script, go away to make a cup of tea, and come back to what I need to focus on.

## Where I need help

### Tests

I TDD'd my code to the best of my ability, but I'm not happy with my tests.

They rely too much on mocks to test behaviour and not enough on the code.

I believe this is a side effect of my lack of Ruby experience and possibly the nature of testing a script instead of a Class or a Module.

No matter what the reason I sense I've got some learning Rspec to do and would appreciate some help.

### Naming

I'm open to name changes. I'm not a fan of the script name and I think some of the method names could be improved too.

### Private methods

I created some private methods but I don't really know where they should live in the script. At the bottom? Close to the method they support? What's the convention?

## Final thought

### Commits

I've sadly added all my code and tests in one giant commit. This is something I normally disapprove of but I got carried away by the excitement of writing Ruby.

Please forgive.

If I want to add this script properly to the project I'll delete my branch and start again to create a proper commit history.