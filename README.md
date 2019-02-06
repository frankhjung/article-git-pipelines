---
title: 'Git Pipelines'
author: '[frank.jung@marlo.com.au](mailto:frank.jung@marlo.com.au)'
date: '6 February 2019'
output:
  html_document: default
---

# Introduction

Git has become the _de facto_ standard for version control. This has given
rise to many vendors hosting Git repositories. Each vendor provides Git
functionality such as branching, pull requests, project membership. There is now
growing competition to provide Continuous Integration / Continuous Delivery
(CI/CD) tools. It has become a very competitive market. One feature that extends
version control beyond just source files, is pipelines. Pipelines are extensible
suite of tools to build, test and deploy source code. Even data hosting sites
like [Kaggle](https://www.kaggle.com/) now support
[pipelines](https://www.kaggle.com/dansbecker/pipelines).

This article provides a brief summary of some pipeline features from three
popular hosted sites, [GitLab](https://gitlab.com/),
[Bitbucket](https://bitbucket.org) and [GitHub](https://github.com/).

This project will be used to show features for each Git repository.

The features being tested are:

* use of Docker images
* customise environment
* stages
* archive of generated artefacts

The workflow is:

1. install [GNU Make](https://www.gnu.org/software/make/)
1. install [pandoc](https://pandoc.org/)
1. render HTML from Markdown
1. archive rendered document

Here are other source repositories that offer pipelines that you may also like
to try:

* [Kaggle](https://www.kaggle.com/)
* [DigitalOcean](https://www.digitalocean.com/)

# [GitLab](https://gitlab.com/)

GitLab pipelines are well integrated tool. CI / CD pipelines are easily accessed
from the sidebar:

![CI/CD on sidebar](images/gitlab-sidebar.png)

Viewing jobs gives you a pipeline run history:

![Pipeline job history](images/gitlab-jobs.png)

The YAML configuration `.gitlab-ci.yml` looks like:

```yaml
image: conoria/alpine-pandoc

variables:
  TARGET: README.html

stages:
  - build

before_script:
  - apk update
  - apk add make

render:
  stage: build
  script:
    - make $TARGET
  artifacts:
    paths:
      - $TARGET
```

Where:

* `image` - specifies a custom Docker image from Docker Hub
* `variables` - define a variable to be used in all jobs
* `stages` - declares the jobs to run
* `before_script` - commands to run before all jobs
* `render` - name of job associated with a stage. Jobs of the same stage are run in parallel
* `stage` - associates a job with a stage
* `script` - commands to run for job
* `artitacts` - path to objects to archive, these can be downloaded if job
  completes successfully

What this configuration does is:

* load a alpine docker image for pandoc
* invoke the build stage which
  * initialises with alpine package update and install
  * runs the `render` job which makes the given target
  * on successful completion, the target HTML is archived for download

GitLab is easy to configure and easy to navigate. There are many other features
including scheduling pipelines, configuring jobs by branch. One feature that I
have used on Maven / Java projects is caching the `.m2` directory. This speeds
up the build as you don't have a completely new environment for each build, but
can rely on previous cached artefacts. GitLab also provides a clear cache button
on the pipeline page. 

GitLab also provides additional services that can be integrated with you
project, for example: JIRA tracking, Kubernetes, Prometheus monitoring.

# [Bitbucket](https://bitbucket.org)

# [GitHub](https://github.com/)

# Summary

Git pipelines will be not suite in every circumstance. There are however, clear
advantages to using a hosted pipeline that ensures that your project builds
somewhere other than your laptop. It also removes the cost of building and
maintaining your own infrastructure. The pipeline configuration is also augments
your projects documentation for build, test and deployment. It is an independent
executable description for your project that explicitly lists dependencies.
Hosted pipelines also lightens the effort for provisioning and maintaining your
own infrastructure. This could be a great benefit to projects where
time constraints limit ones ability to prepare an environment.

# Acknowledgements

* the CSS stylesheet used here based off [killercup/pandoc.css](https://gist.github.com/killercup/5917178)

