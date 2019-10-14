# Introduction
This app implements yet another billing functionality to extend the standard CRM. The app is specifically tailored for my personal needs as a consulting and implementation partner.
It is intended to be used as a template to fork it andcreate your own unlocked package from it with adjustmens you see fit. I will continue to add new functionality as I see needed. 
However, everyone is invited to contribute to this implementation.

# Overview of functionality
In a galaxy far, far away, this app will provide actual Billing / Account Management functionality. For now, you can:
* Create Budgets for your Accounts to keep track of hours logged and hours invoiced (against a budget)
* Log time entries to track your work (and enrich wich different type of services (products) and the logging resource)
* Bill these time entries and generate invoices

For now, I use JIRA to organize work and plan roadmap. So no transparency (yet).

# Contribute
Please contact me if you want to fork the repo or contribute. Lincense is tbd.

## Branching Model
I work with a stable branch `master` and feature / version branches (`feature/StoryId-story-name` and `version/major.minor`) where development is done. To reduce overhead, work can be done in both feature and version branches. Feature branches always merge to version branches. Version branches merge to master.

## Development Workflow
Setup Scratch org using the scripts. This will speed up test data import, permission sets, etc.

Windows:
```shell
.\dev-tools\win\default_init.ps1 -a "ScratchAlias"
```

MacOs:
```shell
bash dev-tools/macOS/default_init.sh
```