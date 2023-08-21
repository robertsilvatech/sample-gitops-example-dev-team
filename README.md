# README.md

- [README.md](#readmemd)
  - [GitOps Settings](#gitops-settings)
    - [Gitlab settings](#gitlab-settings)
    - [Application Repository Configuration (CI Configuration)](#application-repository-configuration-ci-configuration)
      - [Configure CI file (.gitlab-ci.yaml)](#configure-ci-file-gitlab-ciyaml)


## GitOps Settings

### Gitlab settings

- Protected branches
  - Settings > Repository > Protected branches
    - dev
      - Allowed to merge: Maintainers
      - Allowed to push and merge: No one
    - prod
      - Allowed to merge: Maintainers
      - Allowed to push and merge: No one
- GitOps
  - Settings Access Token
    - Token name: argocd
    - Role: Maintainer
    - Scopes: api, read_api, read_respository, write_repository

**sample-gitops-example-dev-team**
> GIT_TOKEN_USER: argocd
> GIT_TOKEN: <generated_token>  

### Application Repository Configuration (CI Configuration)

- Variables
  - Settings > CI/CD > Variables:
    - GIT_TOKEN_USER: argocd
    - GIT_TOKEN: <generated_token>

#### Configure CI file (.gitlab-ci.yaml)

- Add stage `change-image-tag`
```
stages:
  - build
  - change-image-tag
```

- Set new stage `change-image-tag`

> Attention  
> Change the variables:  
> - CONFIG_REPO_NAME: Gitops repository name  
> - PROJECT_FOLDER: Project folder name in the gitops repository  


- Configuration for change imagem o GitOps repository
  
```
change-image-tag-helm: &change-image-tag-helm
  image: 
    name: robertsilvatech/ubuntu-with-git:20.04
    entrypoint: [ '/bin/bash', '-c', 'ln -snf /bin/bash /bin/sh && /bin/bash -c $0' ]
  needs: 
    - docker-build
  stage: change-image-tag
  variables:
    CONFIG_REPO_NAME: sample-gitops-example-dev-team
    PROJECT_FOLDER: sample-python-application
  before_script:
    - git config --global user.email "ci@argo" && git config --global user.name "Gitlab CI"    
  script:
    - echo "cloning config repo $CONFIG_REPO_NAME"
    - git clone "https://$GIT_TOKEN_USER:$GIT_TOKEN@gitlab.com/robertsilvatech/$CONFIG_REPO_NAME.git"
    - echo "Enter $CONFIG_REPO_NAME"
    - cd $CONFIG_REPO_NAME
    - echo "list files"
    - ls -lh
    - git remote -v
    - git checkout -b $CI_PROJECT_NAME-$CI_COMMIT_REF_SLUG-$CI_COMMIT_SHORT_SHA
    - 'ls $PROJECT_FOLDER/helm/values-$CI_COMMIT_REF_SLUG*.yaml | xargs sed -i -r "s/tag: (.*)/tag: $CI_COMMIT_REF_SLUG-$CI_COMMIT_SHORT_SHA/g"'
    - git status
    - git add .
    - git commit -m "Update image tag from CI  on $CI_PROJECT_NAME - $CI_COMMIT_REF_SLUG-$CI_COMMIT_SHORT_SHA"
    - git push origin $CI_PROJECT_NAME-$CI_COMMIT_REF_SLUG-$CI_COMMIT_SHORT_SHA
  only:
    - dev

change-image-tag-helm-prod:
  <<: *change-image-tag-helm
  needs: [ docker-build-prod ]
  only: 
    - prod
```