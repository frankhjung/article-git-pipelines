---
title: 'Git Pipelines'
author: '[frank.jung@marlo.com.au](mailto:frank.jung@marlo.com.au)'
date: '15 August 2019'
output:
  html_document: default
---


# Introduction

Git has become the _de facto_ standard for version control, but until recently 
you needed external tools such as [Jenkins](https://jenkins.io) or
[GoCD](https://www.gocd.org) for managing Continuous Integration /
Continuous Delivery (CI/CD) pipelines. 

Now, though, we're seeing vendors like [Gitlab](https://gitlab.com) and others 
providing pipeline features - extensible suites of tools to build, test and
deploy code. These integrated CI/CD features greatly streamline solution 
delivery and have given rise to whole new ways of doing things like
[GitOps](https://queue.acm.org/detail.cfm?id=3237207).

In this article we demonstrate and compare the current pipeline features from 
three popular Git hosting sites: [GitLab](https://gitlab.com/),
[Bitbucket](https://bitbucket.org) and [GitHub](https://github.com/), and ask 
the question "It it time to switch from your current CI/CD toolset?"

# Exercise

To demonstrate these features, we use pipelines render the [Git
Markdown](https://guides.github.com/features/mastering-markdown/) version of 
this article into an HTML document.

The pipeline features we are exploring are:

* using of Docker images
* customising the build environment
* pipeline stages
* archiving generated artefacts

The pipeline workflow is:

1. install [GNU Make](https://www.gnu.org/software/make/)
1. install [pandoc](https://pandoc.org/) - we are using this to render Markdown to HTML
1. render the HTML document from Markdown
1. archive rendered document

# [GitLab](https://gitlab.com/)

[GitLab](https://gitlab.com/) was launched in 2011. Here we will be evaluating
the features of the Community Edition.

GitLab pipelines are a well integrated tool. The CI/CD
pipelines are easily accessed from the sidebar:

![CI/CD on sidebar](images/gitlab-sidebar.png)

Viewing jobs gives you a pipelines history:

![Pipeline job history](images/gitlab-jobs.png)

The [YAML](https://docs.gitlab.com/ce/ci/yaml/) configuration
[.gitlab-ci.yml](https://github.com/frankhjung/article-git-pipelines/blob/master/.gitlab-ci.yml)
for this pipeline is:

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

* `image` - specifies a custom Docker image from Docker Hub (can be custom per *job*)
* `variables` - define a variable to be used in all *jobs*
* `stages` - declares the jobs to run
* `before_script` - commands to run before all *jobs*
* `render` - name of *job* associated with a stage. Jobs of the same stage are run in parallel
* `stage` - associates a *job* with a stage
* `script` - commands to run for this *job*
* `artitacts` - path to objects to archive, these can be downloaded if the *job* completes successfully

What this pipeline configuration does is:

* load an Alpine Docker image for [pandoc](https://pandoc.org/)
* invoke the build stage which
  * initialises with alpine package update and install
  * runs the `render` job which generates the given target HTML
  * on successful completion, the target HTML is archived for download

GitLab is easy to configure and easy to navigate. There are many other features
including scheduling pipelines and the ability to configuring jobs by branch.
One feature that I have used on Java / Maven projects is caching of the `.m2`
directory. This speeds up the build as you don't have a completely new
environment for each build, but can leverage previous cached artefacts. GitLab
also provides a _clear cache_ button on the pipeline page.

GitLab also supports hosting of static
[pages](https://about.gitlab.com/product/pages/). This is simple to set-up and
use, requiring only an additional `pages` job in the deployment `stage` to move
static content into a directory called `public`. This makes it very easy to host
a projects generated documentation and test results.

Finally, GitLab provides additional services that can be integrated with your
project. For example: [JIRA](https://www.atlassian.com/software/jira) tracking,
[Kubernetes](https://kubernetes.io/), and monitoring using
[Prometheus](https://prometheus.io/).


# [Bitbucket](https://bitbucket.org)

Atlassian's [Bitbucket](https://bitbucket.org) was launched in 2008. As such it
integrates with other Atlassian software like Jira, HipChat, Confluence and Bamboo.

This example project is publicly available [here](https://gitlab.com/frankhjung1/article-git-pipelines).

The pipeline configuration is similar to that from GitLab. Pipelines and settings are
easily navigated into using the side-bar.

![Pipeline job history](images/bitbucket-jobs.png)

The pipeline configuration is also similar. But there are important differences.
Below is the configuration file
[bitbucket-pipelines.yml](https://bitbucket.org/frankhjung/articles-git-pipelines/src/master/bitbucket-pipelines.yml):

```yaml
pipelines:
  branches:
    master:
      - step:
          name: render
          image: conoria/alpine-pandoc
          trigger: automatic
          script:
            - apk update && apk add make curl
            - export TARGET=README.html
            - make -B ${TARGET}
            - curl -X POST --user "${BB_AUTH_STRING}" +
                "https://api.bitbucket.org/2.0/" +
                "repositories/${BITBUCKET_REPO_OWNER}/" +
                "${BITBUCKET_REPO_SLUG}/downloads " +
                --form files=@"${TARGET}"
```

Here the pipeline will be triggered automatically on commits to `master` branch.
A Docker image can be defined at the level of the pipeline step. Variables can
be defined and read from the Bitbucket settings page. This is useful for
recording secrets that you don't want to have exposed in your source code.
However, internal script variables are set via the script language, which here
is Bash. Finally, in order for the build artefacts to be preserved after the
pipeline completes, you can publish to a downloads location. This requires that
a secure variable be configured, as described
[here](https://confluence.atlassian.com/bitbucket/deploy-build-artifacts-to-bitbucket-downloads-872124574.html).
If you don't, the pipeline workspace is purged on completion.

![Downloads](images/bitbucket-downloads.png)

Pipeline build performance is very good, where this entire step took only around
11 seconds to complete.

One limitation is that the free account limits you to only 50 minutes per month
with 1GB storage.

That you have to externally / manually configure repository settings has some
benefits. The consequence though, is that there are then settings that are not
recorded by your project.

A feature of being able to customise the Docker image used at the step level is
that your build and test steps can use different images. This is great if you
want to trial your application on a production like image.


# [GitHub](https://github.com/)

GitHub has been around since 2008. It was recently [acquired by
Microsoft](https://blogs.microsoft.com/blog/2018/10/26/microsoft-completes-github-acquisition/).
It hosts over 100 million repositories with more than 40 million registered
users ([source](https://github.com/about/facts)).

When you create a GitHub repository, there is an option to include [Azure
Pipelines](https://azure.microsoft.com/en-au/services/devops/pipelines/).
However this is not integrated to GitHub directly, but is configured under [Azure
DevOps](https://dev.azure.com/). Broadly, the steps to set-up a pipeline are:

* sign up to Azure pipelines
* create a project
* add GitHub repository to project
* configure pipeline job

![Azure DevOps Pipelines](images/azure-pipelines.png)

Builds are managed from the Azure DevOps dashboard. There appears to be no way
to manually trigger a build directly from the GitHub repository. Though, if you
commit, it will happily trigger a build for you. But, again, you need to be on
the Azure DevOps dashboard to monitor the pipeline jobs.

The following
[YAML](https://docs.microsoft.com/en-us/azure/devops/pipelines/yaml-schema)
configuration uses a Ubuntu 16.04 image provided by Azure. There are limited
number of images, but they are well maintained with packages kept up-to-date.
They come with [many pre-installed
packages](https://github.com/Microsoft/azure-pipelines-image-generation/blob/master/images/linux/Ubuntu1604-README.md).

Below is the Azure pipeline configuration
[azure-pipelines.yml](https://github.com/frankhjung/article-git-pipelines/blob/master/azure-pipelines.yml):

```yaml
trigger:
  - master

pool:
  vmImage: 'Ubuntu-16.04'

steps:

  - script: |
      sudo apt-get install pandoc
    displayName: 'install_pandoc'

  - script: |
      make -B README.html
    displayName: 'render'

  - powershell: |
      gci env:* |
      sort-object name |
      Format-Table -AutoSize |
      Out-File $env:BUILD_ARTIFACTSTAGINGDIRECTORY/environment-variables.txt

  - task: PublishBuildArtifacts@1
    inputs:
      pathtoPublish: '$(System.DefaultWorkingDirectory)/README.html'
      artifactName: README
```

If the package you need is not installed, then you can install it if available
from the Ubuntu package repositories. The default user profile is not `root`, so
installation requires `sudo`.

![Azure DevOps Job History](images/azure-job.png)

To create an archive of artefacts for download, you need to invoke a specific
[PublishBuildArtifacts](https://docs.microsoft.com/en-us/azure/devops/pipelines/artifacts/build-artifacts?view=azure-devops&tabs=yaml)
task.

![Azure DevOps Download Artefacts](images/azure-artefacts.png)

Azure is fast as it uses images that Microsoft manages and hosts. The above job
to install `pandoc` and render this page as HTML takes only 1 minute.

I found the biggest negative to Azure Pipelines was the poor integration to the
GitHub dashboard. Instead, you are strongly encouraged to manage pipelines using
the [Azure
DevOps](https://docs.microsoft.com/en-us/azure/devops/report/dashboards)
dashboard.


## Addendum

Since writing this there has been an announcement from GitHub on support of
pipeline automation called [GitHub
Actions](https://github.com/features/actions/). I've registered to the Beta
program and hopefully will have some new information to post here shortly.

# Summary

Git pipelines will not be suitable in every circumstance. For example Ansible
infrastructure projects. There are clear advantages to using a hosted pipeline
that ensures that your project builds somewhere other than on your machine. It
also removes the cost of building and maintaining your own infrastructure. The
pipeline configuration augments your projects documentation for build, test and
deployment. It is an independent executable description for your project that
explicitly lists dependencies. Hosted pipelines ease the effort for
provisioning and maintaining your own CI/CD infrastructure. This could be of great
benefit to projects where time constraints limit ones ability to prepare an
environment.

Marlo is constantly looking at ways to increase our productivity and
effectiveness in delivering solutions. Using hosted services like GitLab,
further enables Marlo's Digital Enablement Platform.


# Acknowledgements

* the CSS stylesheet used here based off [killercup/pandoc.css](https://gist.github.com/killercup/5917178)


# Links

This project can be viewed from these Git repositories:

* https://bitbucket.org/frankhjung/articles-git-pipelines
* https://github.com/frankhjung/article-git-pipelines
* https://gitlab.com/frankhjung1/article-git-pipelines
* https://gitlab.com/theMarloGroup/articles/git-pipelines

There are many more repository hosting sites that offer pipelines. You may like
to explore:

* [Kaggle](https://www.kaggle.com/)
* [DigitalOcean](https://www.digitalocean.com/)
* [Travis CI](https://travis-ci.org/)
