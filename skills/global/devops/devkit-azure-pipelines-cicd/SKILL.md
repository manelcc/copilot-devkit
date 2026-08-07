---
name: "devkit-azure-pipelines-cicd"
description: >
  Genera y valida pipelines Azure DevOps cross-stack: Kotlin/Ktor, Python FastAPI, Android, iOS.
  Modelo dos imágenes Docker (CI runner una sola vez + app por push), stages build/test/docker-build/docker-push/deploy,
  Azure Container Registry (ACR), staging automático en OpenShift y producción en Google Cloud Run con aprobación manual.
applyTo:
  - "azure-pipelines.yml"
  - "Dockerfile"
triggers:
  - "crea el pipeline de azure"
  - "configura azure devops"
  - "genera el azure-pipelines.yml"
  - "pipeline para azure"
  - "azure container registry"
  - "acr"
  - "azure devops pipeline"
  - "azure pipelines para android"
  - "azure pipelines para ios"
  - "azure pipelines para python"
nonTriggers:
  - Pipeline de GitLab CI (usar devkit-gitlab-cicd)
  - Pipeline de GitHub Actions (usar devkit-github-actions-cicd)
  - Implementación de código (usar el stack expert correspondiente)
governance: devkit-devops
scope: global
---

# Azure Pipelines CI/CD

## Purpose

Genera pipelines Azure DevOps completos para el proyecto MCP Server ShareResources:
build Gradle, tests con JaCoCo, Docker multi-stage, publicación en Azure Container
Registry (ACR), deploy staging en **OpenShift** y prod en **Google Cloud Run** con aprobación manual.


## When to use
- User asks to set up CI/CD for a Azure DevOps project
- User needs to generate or update `azure-pipelines.yml`
- User needs Docker build, registry push, or deployment pipeline for any stack

## When NOT to use
- User asks for application code → delegate to the relevant stack expert agent
- User asks about git branching conventions → use `devkit-git-operations` skill
- User needs only the environment/branch strategy → use `devkit-environments-cicd`

## Inputs
- Stack (Kotlin/Ktor, Python, Spring, Android, iOS, KMP)
- Registry type (GitLab CR / GHCR / ACR / custom)
- Staging deploy target (OpenShift / Kubernetes / ECS)
- Production deploy target (Google Cloud Run / App Store / Play Store)
- Secret/variable names for registry credentials and deploy keys

## Steps
See detailed pipeline sections below.

---

## Modelo de imágenes Docker

Existen **dos imágenes Docker** con ciclos de vida distintos:

| Imagen | Fichero | Cuándo se construye | Tag en ACR | Propósito |
|---|---|---|---|---|
| **CI Runner** | `Dockerfile.ci` | **Una sola vez** al crear el repo; si cambia `Dockerfile.ci` | `<acr>/ci-runner:latest` | Base de todos los jobs CI/CD. JDK 21 + Gradle + dependencias pre-cacheadas |
| **Aplicación** | `Dockerfile` | En cada push a `develop` o `main` | `<acr>/<app>:$(Build.BuildId)` | Imagen del MCP server. Se despliega en local, OpenShift y Cloud Run |

---

## Dockerfile.ci — Imagen CI Runner (construir UNA sola vez)

```dockerfile
# Dockerfile.ci — CI Runner: JDK 21 + Gradle + dependencias pre-cacheadas
# Registrar en ACR al crear el repositorio (ver azure-pipelines-ci-image.yml).
# Actualizar solo si cambian las dependencias Gradle o la versión de JDK.
FROM eclipse-temurin:21-jdk-alpine
WORKDIR /ci-workspace
COPY gradle/ gradle/
COPY gradlew ./
COPY build.gradle.kts settings.gradle.kts ./
RUN chmod +x ./gradlew && \
    ./gradlew dependencies --no-daemon --quiet 2>/dev/null || true
```

## Pipeline azure-pipelines-ci-image.yml — Construir CI Runner (UNA VEZ)

```yaml
# azure-pipelines-ci-image.yml
# Ejecutar manualmente al crear el repo o automáticamente si cambia Dockerfile.ci
trigger:
  paths:
    include:
      - Dockerfile.ci

variables:
  ACR_NAME:       $(acrName)         # Variable group: mcp-cicd-vars
  CI_IMAGE_NAME:  mcp-server-ci-runner

stages:
  - stage: BuildCiImage
    displayName: 'Build CI Runner Image (one-time setup)'
    jobs:
      - job: BuildCiImageJob
        displayName: 'Build & Push CI Runner to ACR'
        pool:
          vmImage: 'ubuntu-latest'
        steps:
          - task: Docker@2
            displayName: 'Login to ACR'
            inputs:
              command:           'login'
              containerRegistry: 'mcp-acr-service-connection'

          - task: Docker@2
            displayName: 'Build CI runner image'
            inputs:
              command:    'build'
              Dockerfile: 'Dockerfile.ci'
              tags: |
                $(ACR_NAME).azurecr.io/$(CI_IMAGE_NAME):latest
                $(ACR_NAME).azurecr.io/$(CI_IMAGE_NAME):$(Build.BuildId)

          - task: Docker@2
            displayName: 'Push CI runner image'
            inputs:
              command: 'push'
              tags: |
                $(ACR_NAME).azurecr.io/$(CI_IMAGE_NAME):latest
                $(ACR_NAME).azurecr.io/$(CI_IMAGE_NAME):$(Build.BuildId)
```

## Dockerfile — Imagen de aplicación (construir en cada push)

```dockerfile
# Dockerfile — Imagen del MCP server
# ARG CI_IMAGE: imagen CI runner del ACR (Gradle + dependencias cacheadas)
ARG CI_IMAGE=eclipse-temurin:21-jdk-alpine

# Stage 1: build (usa la imagen CI runner)
FROM ${CI_IMAGE} AS builder
WORKDIR /app
COPY . .
RUN ./gradlew shadowJar --no-daemon

# Stage 2: runtime (imagen mínima)
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
COPY --from=builder /app/build/libs/*-all.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
```

## docker-compose.yml — Testing en local

```yaml
# docker-compose.yml — Para ejecutar el MCP server en local (sin registry)
services:
  mcp-server:
    image: mcp-server:local
    build:
      context: .
      dockerfile: Dockerfile
      args:
        CI_IMAGE: eclipse-temurin:21-jdk-alpine  # local no usa registry
    ports:
      - "8080:8080"
    environment:
      DB_URL:      jdbc:postgresql://postgres:5432/mcp_dev
      DB_USER:     mcp
      DB_PASSWORD: mcp_secret
    depends_on:
      postgres:
        condition: service_healthy
  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB:       mcp_dev
      POSTGRES_USER:     mcp
      POSTGRES_PASSWORD: mcp_secret
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U mcp"]
      interval: 10s
      timeout: 5s
      retries: 5
```

---

## Pipeline azure-pipelines.yml

```yaml
# azure-pipelines.yml
trigger:
  branches:
    include:
      - develop
      - main

pr:
  branches:
    include:
      - develop
      - main

variables:
  ACR_NAME:       $(acrName)           # Variable group: mcp-cicd-vars
  CI_IMAGE:       $(acrName).azurecr.io/mcp-server-ci-runner:latest  # Imagen CI runner (construida una sola vez)
  IMAGE_NAME:     mcp-server-shareresources
  IMAGE_TAG:      $(Build.SourceVersion)
  GRADLE_OPTS:    -Dorg.gradle.daemon=false

stages:
  # ── Stage: Build (usa imagen CI runner del ACR) ──────────────────────
  - stage: Build
    displayName: 'Build'
    jobs:
      - job: BuildJob
        displayName: 'Gradle Build'
        pool:
          vmImage: 'ubuntu-latest'
        container:
          image: $(CI_IMAGE)
          endpoint: mcp-acr-service-connection   # Service Connection para acceder al ACR
        steps:
          - task: Cache@2
            inputs:
              key:    'gradle | "$(Agent.OS)" | **/*.gradle.kts'
              path:   '$(HOME)/.gradle'
              restoreKeys: 'gradle | "$(Agent.OS)"'
            displayName: 'Cache Gradle'

          - script: ./gradlew assemble --no-daemon
            displayName: 'Assemble'

          - task: PublishPipelineArtifact@1
            inputs:
              targetPath:   '$(Build.SourcesDirectory)/build/libs'
              artifact:     'build-libs'
            displayName: 'Publish build artifacts'

  # ── Stage: Test (usa imagen CI runner + servicio postgres) ─────────────
  - stage: Test
    displayName: 'Test'
    dependsOn: Build
    jobs:
      - job: TestJob
        displayName: 'JUnit5 + JaCoCo'
        pool:
          vmImage: 'ubuntu-latest'
        container:
          image: $(CI_IMAGE)
          endpoint: mcp-acr-service-connection   # Service Connection para acceder al ACR
        services:
          postgres:
            image: postgres:15-alpine
            env:
              POSTGRES_DB:       mcp_test
              POSTGRES_USER:     mcp
              POSTGRES_PASSWORD: mcp_secret
            ports:
              - 5432:5432
        variables:
          DB_URL:      jdbc:postgresql://localhost:5432/mcp_test
          DB_USER:     mcp
          DB_PASSWORD: mcp_secret
        steps:
          - task: JavaToolInstaller@0
            inputs:
              versionSpec:          '21'
              jdkArchitectureOption: 'x64'
              jdkSourceOption:      'PreInstalled'

          - task: Cache@2
            inputs:
              key:  'gradle | "$(Agent.OS)" | **/*.gradle.kts'
              path: '$(HOME)/.gradle'

          - script: ./gradlew test jacocoTestReport jacocoTestCoverageVerification --no-daemon
            displayName: 'Test + Coverage'

          - task: PublishTestResults@2
            inputs:
              testResultsFormat: 'JUnit'
              testResultsFiles:  '**/TEST-*.xml'
            condition: always()

          - task: PublishCodeCoverageResults@2
            inputs:
              summaryFileLocation: '$(Build.SourcesDirectory)/build/reports/jacoco/test/jacocoTestReport.xml'

  # ── Stage: DockerBuild (imagen de aplicación) ─────────────────────────
  - stage: DockerBuild
    displayName: 'Docker Build'
    dependsOn: Test
    condition: and(succeeded(), or(eq(variables['Build.SourceBranch'], 'refs/heads/develop'), eq(variables['Build.SourceBranch'], 'refs/heads/main')))
    jobs:
      - job: DockerBuildJob
        displayName: 'Build Docker app image (usa CI runner como builder)'
        pool:
          vmImage: 'ubuntu-latest'
        steps:
          - task: DownloadPipelineArtifact@2
            inputs:
              artifact:    'build-libs'
              targetPath:  '$(Build.SourcesDirectory)/build/libs'

          - task: Docker@2
            displayName: 'Build app image'
            inputs:
              command:    'build'
              Dockerfile: 'Dockerfile'
              arguments:  '--build-arg CI_IMAGE=$(CI_IMAGE)'
              tags:       |
                $(ACR_NAME).azurecr.io/$(IMAGE_NAME):$(IMAGE_TAG)
                $(ACR_NAME).azurecr.io/$(IMAGE_NAME):latest

  # ── Stage: DockerPush ───────────────────────────────────────────────────
  - stage: DockerPush
    displayName: 'Docker Push'
    dependsOn: DockerBuild
    condition: and(succeeded(), or(eq(variables['Build.SourceBranch'], 'refs/heads/develop'), eq(variables['Build.SourceBranch'], 'refs/heads/main')))
    jobs:
      - job: DockerPushJob
        displayName: 'Push to ACR'
        pool:
          vmImage: 'ubuntu-latest'
        steps:
          - task: Docker@2
            displayName: 'Login to ACR'
            inputs:
              command:           'login'
              containerRegistry: 'mcp-acr-service-connection'  # Service Connection en Azure DevOps

          - task: Docker@2
            displayName: 'Push image'
            inputs:
              command: 'push'
              tags:    |
                $(ACR_NAME).azurecr.io/$(IMAGE_NAME):$(IMAGE_TAG)
                $(ACR_NAME).azurecr.io/$(IMAGE_NAME):latest

  # ── Stage: DeployStaging → OpenShift (automático en develop) ───────────
  - stage: DeployStaging
    displayName: 'Deploy Staging → OpenShift'
    dependsOn: DockerPush
    condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/develop'))
    jobs:
      - deployment: DeployStagingJob
        displayName: 'Deploy to OpenShift Staging'
        environment: 'staging'
        pool:
          vmImage: 'ubuntu-latest'
        strategy:
          runOnce:
            deploy:
              steps:
                - script: |
                    curl -fsSL https://mirror.openshift.com/pub/openshift-v4/clients/oc/latest/linux/oc.tar.gz | tar xz
                    sudo mv oc /usr/local/bin/
                  displayName: 'Install oc CLI'

                - script: |
                    oc login $(OC_SERVER) --token=$(OC_TOKEN) --insecure-skip-tls-verify=false
                    oc -n $(OC_NAMESPACE_STAGING) set image deployment/$(APP_NAME)                       $(APP_NAME)=$(ACR_NAME).azurecr.io/$(IMAGE_NAME):$(IMAGE_TAG)
                    oc -n $(OC_NAMESPACE_STAGING) rollout status deployment/$(APP_NAME) --timeout=5m
                  displayName: 'Deploy to OpenShift'

  # ── Stage: DeployProd → Cloud Run (manual con aprobación) ───────────────
  - stage: DeployProd
    displayName: 'Deploy Production → Cloud Run'
    dependsOn: DockerPush
    condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
    jobs:
      - deployment: DeployProdJob
        displayName: 'Deploy to Google Cloud Run'
        environment: 'production'    # Configurar Approvals en Azure DevOps Environments
        pool:
          vmImage: 'ubuntu-latest'
        strategy:
          runOnce:
            deploy:
              steps:
                - task: GoogleCloudSdkTool@0
                  inputs:
                    version: 'latest'
                  displayName: 'Install gcloud SDK'

                - script: |
                    echo $(GCP_SA_KEY) | gcloud auth activate-service-account --key-file=-
                    gcloud config set project $(GCP_PROJECT_ID)
                    gcloud run deploy $(CLOUD_RUN_SERVICE)                       --image=$(ACR_NAME).azurecr.io/$(IMAGE_NAME):$(IMAGE_TAG)                       --region=$(GCP_REGION)                       --platform=managed                       --allow-unauthenticated=false                       --quiet
                  displayName: 'Deploy to Cloud Run'
```

---

## Variable Groups y Secrets en Azure DevOps

Configurar en **Pipelines → Library → Variable Groups** (`mcp-cicd-vars`):

| Variable | Descripción | Secret |
|---|---|---|
| `acrName` | Nombre del Azure Container Registry | ❌ |
| `APP_NAME` | Nombre del deployment en OpenShift | ❌ |
| `OC_SERVER` | URL del servidor OpenShift (ej: `https://api.cluster:6443`) | ❌ |
| `OC_TOKEN` | Token del service account de OpenShift | ✅ |
| `OC_NAMESPACE_STAGING` | Namespace OpenShift para staging | ❌ |
| `OC_STAGING_URL` | URL del entorno staging en OpenShift | ❌ |
| `GCP_PROJECT_ID` | ID del proyecto Google Cloud | ❌ |
| `GCP_SA_KEY` | JSON del Service Account de GCP | ✅ |
| `GCP_REGION` | Región de Cloud Run (ej: `europe-west1`) | ❌ |
| `CLOUD_RUN_SERVICE` | Nombre del servicio Cloud Run | ❌ |
| Secretos de DB prod | Conexión a la DB de producción | ✅ |

> **Service Connection:** Crear un Service Connection de tipo Docker Registry hacia el ACR en **Project Settings → Service Connections**, con nombre `mcp-acr-service-connection`. Se usa también para acceder a la imagen CI runner desde los stages de Build y Test.

> **Aprobación manual prod:** Configurar en **Pipelines → Environments → production → Approvals and checks → Approvals**.

---

## Validation

- [ ] **AZ-01** Stages en orden con `dependsOn`: `Build → Test → DockerBuild → DockerPush → Deploy`
- [ ] **AZ-02** Servicio `postgres` en el stage `Test`
- [ ] **AZ-03** `DockerPush` condicionado a ramas `develop` y `main`
- [ ] **AZ-04** Environment `production` con Approval configurado en Azure DevOps
- [ ] **AZ-05** Credenciales en Variable Groups, no hardcodeadas en el YAML
- [ ] **AZ-06** Service Connection `mcp-acr-service-connection` creado y referenciado en Build, Test y DockerPush
- [ ] **AZ-07** Cache de Gradle con `task: Cache@2`
- [ ] **AZ-08** Imagen app tagged con `$(Build.SourceVersion)` y `latest`
- [ ] **AZ-09** `Dockerfile.ci` existe y pipeline `azure-pipelines-ci-image.yml` creado
- [ ] **AZ-10** Stages `Build` y `Test` usan `container: $(CI_IMAGE)` con el Service Connection del ACR
- [ ] **AZ-11** Deploy staging usa `oc set image` + `oc rollout status` en OpenShift
- [ ] **AZ-12** Deploy prod usa `gcloud run deploy` con `--allow-unauthenticated=false`
- [ ] **AZ-13** `OC_TOKEN` y `GCP_SA_KEY` configurados como secrets en el Variable Group
- [ ] **AZ-14** `docker-compose.yml` disponible para testing en local sin registry

---

## Expected outputs

- `azure-pipelines-ci-image.yml` para construir la imagen CI runner (una sola vez).
- `azure-pipelines.yml` con 6 stages; `Build` y `Test` usan `container: $(CI_IMAGE)`.
- `Dockerfile.ci` para la imagen CI runner (JDK 21 + Gradle + dependencias).
- `Dockerfile` multi-stage para la imagen de aplicación (usa `ARG CI_IMAGE`).
- `docker-compose.yml` para testing local.
- Variable Group `mcp-cicd-vars` documentado con nuevas variables OpenShift y GCP.
- Environment `production` con aprobación manual en Azure DevOps.

## Examples
- "Set up GitLab CI for my Kotlin/Ktor service with OpenShift staging and Cloud Run prod"
- "Add GitHub Actions pipeline with GHCR registry and manual production approval"
- "Migrate my Azure DevOps pipeline to GitHub Actions"
