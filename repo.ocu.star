load("github.com/ocuroot/sdk/v0/repo.star", "repo")
load("github.com/ocuroot/sdk/v0/environments.star", "environment")

repo(id="github.com/ocuroot/quickstart")

environment(name="staging", attributes={ "type": "staging" })
environment(name="prod1", attributes={ "type": "prod" })
environment(name="prod2", attributes={ "type": "prod" })
