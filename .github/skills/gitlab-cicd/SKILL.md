---
name: "gitlab-cicd"
description: >
  Genera y valida pipelines GitLab CI para el proyecto Kotlin/Ktor: imagen CI runner (una sola vez
  por repo), stages build/test/docker-build/docker-push/deploy, GitLab Container Registry,
  staging automático en OpenShift y producción en Google Cloud Run con aprobación manual.
applyTo:
  - ".gitlab-ci.yml"
  - "Dockerfile"
triggers:
  - "crea el pipeline de gitlab"
  - "configura gitlab ci"
  - "genera el .gitlab-ci.yml"
  - "pipeline para gitlab"
  - "gitlab container registry"
  - "stage de docker en gitlab"
nonTriggers:
  - Pipeline de GitHub Actions (usar github-actions-cicd)
  - Pipeline de Azure Pipelines (usar azure-pipelines-cicd)
  - Implementación de código Kotlin (usar kotlin-mcp-expert)
---

# GitLab CI/CD

## Propósito

Genera pipelines GitLab CI completos para el proyecto MCP Server ShareResources:
build Gradle, tests con cobertura JaCoCo, Docker multi-stage build, publicación
en GitLab Container Registry, deploy staging en **OpenShift** y prod en **Google Cloud Run**.

---

## Modelo de imágenes Docker

Existen **dos imágenes Docker** con ciclos de vida distintos:

| Imagen | Fichero | Cuándo se construye | Tag en registry | Propósito |
|---|---|---|---|---|
| **CI Runner** | `Dockerfile.ci` | **Una sola vez** al crear el repo; si cambia `Dockerfile.ci` | `<registry>/ci-runner:latest` | Base de todos los jobs CI/CD. JDK 21 + Gradle + dependencias pre-cacheadas |
| **Aplicación** | `Dockerfile` | En cada push a `develop` o `main` | `<registry>:$CI_COMMIT_SHORT_SHA` | Imagen del MCP server. Se despliega en local, OpenShift y Cloud Run |

---

## Dockerfile.ci — Imagen CI Runner (construir UNA sola vez)

```dockerfile
# Dockerfile.ci — CI Runner: JDK 21 + Gradle + dependencias pre-cacheadas
# Registrar en GitLab Container Registry al crear el repositorio.
# Actualizar solo si cambian las dependencias Gradle o la versión de JDK.
FROM eclipse-temurin:21-jdk-alpine
WORKDIR /ci-workspace
# Solo los ficheros de dependencias para maximizar el layer cache
COPY gradle/ gradle/
COPY gradlew ./
COPY build.gradle.kts settings.gradle.kts ./
RUN chmod +x ./gradlew && \
    ./gradlew dependencies --no-daemon --quiet 2>/dev/null || true
```

## Pipeline ci-image — Construir la imagen CI Runner (UNA VEZ por repo)

> **Nota:** Usar Kaniko en lugar de `docker:24 + DinD`. Los runners Kubernetes (ej. Sopra Steria)
> no tienen acceso al socket Docker y no pueden ejecutar Buildah/Podman sin `--privileged`.
> Kaniko ejecuta el build en modo userspace sin necesidad de privilegios especiales.

```yaml
# .gitlab-ci-image.yml — Ejecutar manualmente al crear el repo
# o automáticamente cuando cambia Dockerfile.ci
stages:
  - build-ci-image

variables:
  CI_IMAGE_NAME: $CI_REGISTRY_IMAGE/ci-runner

build-ci-image:
  stage: build-ci-image
  image:
    name: gcr.io/kaniko-project/executor:v1.23.0-debug
    entrypoint: [""]
  before_script:
    - mkdir -p /kaniko/.docker
    - >-
      echo "{\"auths\":{\"$CI_REGISTRY\":{\"auth\":\"$(printf "%s:%s"
      "$CI_REGISTRY_USER" "$CI_REGISTRY_PASSWORD" | base64 | tr -d '\n')\"}}}"
      > /kaniko/.docker/config.json
  script:
    - >-
      /kaniko/executor
      --context "${CI_PROJECT_DIR}"
      --dockerfile "${CI_PROJECT_DIR}/Dockerfile.ci"
      --destination "${CI_IMAGE_NAME}:latest"
      --destination "${CI_IMAGE_NAME}:${CI_COMMIT_SHORT_SHA}"
  rules:
    - if: '$CI_PIPELINE_SOURCE == "push"'
      changes:
        - Dockerfile.ci
    - when: manual
```

## Dockerfile — Imagen de aplicación (construir en cada push)

```dockerfile
# Dockerfile — Imagen del MCP server
# ARG CI_IMAGE: imagen CI runner del registry (Gradle + dependencias cacheadas)
ARG CI_IMAGE=eclipse-temurin:21-jdk-alpine

# Stage 1: build (usa la imagen CI runner pre-construida)
FROM ${CI_IMAGE} AS builder
WORKDIR /app
COPY . .
RUN ./gradlew shadowJar --no-daemon

# Stage 2: runtime (imagen mínima para producción)
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

## Pipeline .gitlab-ci.yml

```yaml
# .gitlab-ci.yml
stages:
  - build
  - test
  - docker-build
  - docker-push
  - deploy

variables:
  GRADLE_OPTS:  "-Dorg.gradle.daemon=false"
  IMAGE_NAME:   $CI_REGISTRY_IMAGE
  IMAGE_TAG:    $CI_COMMIT_SHORT_SHA
  CI_IMAGE:     $CI_REGISTRY_IMAGE/ci-runner:latest  # Imagen CI runner (construida una sola vez)

# ── Cache de dependencias Gradle ──────────────────────────────────────────────
.gradle-cache: &gradle-cache
  cache:
    key: "$CI_PROJECT_ID-gradle"
    paths:
      - .gradle/
      - build/

# ── Stage: build ──────────────────────────────────────────────────────────────
build:
  stage: build
  image: $CI_IMAGE   # Usa la imagen CI runner pre-construida del registry
  <<: *gradle-cache
  script:
    - ./gradlew assemble --no-daemon
  artifacts:
    paths:
      - build/libs/
    expire_in: 1 hour

# ── Stage: test ───────────────────────────────────────────────────────────────
test:
  stage: test
  image: $CI_IMAGE   # Usa la imagen CI runner pre-construida del registry
  <<: *gradle-cache
  services:
    - name: postgres:15-alpine
      alias: postgres
  variables:
    POSTGRES_DB:       mcp_test
    POSTGRES_USER:     mcp
    POSTGRES_PASSWORD: mcp_secret
    DB_URL:            jdbc:postgresql://postgres:5432/mcp_test
    DB_USER:           mcp
    DB_PASSWORD:       mcp_secret
  script:
    - ./gradlew test jacocoTestReport jacocoTestCoverageVerification --no-daemon
  artifacts:
    reports:
      junit: build/test-results/test/TEST-*.xml
    paths:
      - build/reports/jacoco/
    expire_in: 7 days
  coverage: '/Total.*?([0-9]{1,3})%/'

# ── Stage: docker-build + push (Kaniko — sin DinD, compatible con Kubernetes) ──
docker-build:
  stage: docker-build
  image:
    name: gcr.io/kaniko-project/executor:v1.23.0-debug
    entrypoint: [""]
  before_script:
    - mkdir -p /kaniko/.docker
    - >-
      echo "{\"auths\":{\"$CI_REGISTRY\":{\"auth\":\"$(printf "%s:%s"
      "$CI_REGISTRY_USER" "$CI_REGISTRY_PASSWORD" | base64 | tr -d '\n')\"}}}"
      > /kaniko/.docker/config.json
  script:
    - >-
      /kaniko/executor
      --context "${CI_PROJECT_DIR}"
      --dockerfile "${CI_PROJECT_DIR}/Dockerfile"
      --destination "${IMAGE_NAME}:${IMAGE_TAG}"
      --destination "${IMAGE_NAME}:latest"
  dependencies:
    - build
  only:
    - develop
    - main

# ── Stage: deploy staging → OpenShift (automático en develop) ────────────────
deploy-staging:
  stage: deploy
  image: bitnami/kubectl:latest
  environment:
    name: staging
    url:  $OC_STAGING_URL
  script:
    - oc login $OC_SERVER --token=$OC_TOKEN --insecure-skip-tls-verify=false
    - oc -n $OC_NAMESPACE_STAGING set image deployment/$APP_NAME
        $APP_NAME=$IMAGE_NAME:$IMAGE_TAG
    - oc -n $OC_NAMESPACE_STAGING rollout status deployment/$APP_NAME --timeout=5m
  only:
    - develop
  dependencies:
    - docker-push

# ── Stage: deploy prod → Cloud Run (manual con aprobación) ───────────────────
deploy-prod:
  stage: deploy
  image: google/cloud-sdk:alpine
  environment:
    name: production
    url:  $CLOUD_RUN_URL
  when: manual
  before_script:
    - echo $GCP_SA_KEY | gcloud auth activate-service-account --key-file=-
    - gcloud config set project $GCP_PROJECT_ID
  script:
    - |
      gcloud run deploy $CLOUD_RUN_SERVICE \
        --image=$IMAGE_NAME:$IMAGE_TAG \
        --region=$GCP_REGION \
        --platform=managed \
        --allow-unauthenticated=false \
        --quiet
  only:
    - main
  dependencies:
    - docker-push
```

---

## Variables de CI/CD en GitLab

Configurar en **Settings → CI/CD → Variables** (nunca en el .yml):

| Variable | Descripción | Protected | Masked |
|---|---|---|---|
| `APP_NAME` | Nombre del deployment en OpenShift | ✅ | ❌ |
| `OC_SERVER` | URL del servidor OpenShift (ej: `https://api.cluster:6443`) | ✅ | ❌ |
| `OC_TOKEN` | Token del service account de OpenShift | ✅ | ✅ |
| `OC_NAMESPACE_STAGING` | Namespace OpenShift para staging | ✅ | ❌ |
| `OC_STAGING_URL` | URL del entorno staging en OpenShift | ✅ | ❌ |
| `GCP_PROJECT_ID` | ID del proyecto Google Cloud | ✅ | ❌ |
| `GCP_SA_KEY` | JSON del Service Account de GCP (base64 o raw) | ✅ | ✅ |
| `GCP_REGION` | Región de Cloud Run (ej: `europe-west1`) | ✅ | ❌ |
| `CLOUD_RUN_SERVICE` | Nombre del servicio Cloud Run | ✅ | ❌ |
| `CLOUD_RUN_URL` | URL del servicio Cloud Run (generada por GCP) | ✅ | ❌ |
| `DB_URL` | Sobreescribe para prod | ✅ | ❌ |
| Secretos de DB | Usar GitLab Secrets o Vault | ✅ | ✅ |

Las variables `CI_REGISTRY_USER`, `CI_REGISTRY_PASSWORD` y `CI_REGISTRY` las provee GitLab automáticamente.

---

## Checklist de revisión

- [ ] **GL-01** Stages en orden: `build → test → docker-build → docker-push → deploy`
- [ ] **GL-02** Tests con servicio `postgres` para integración (no H2 en CI si hay servicio disponible)
- [ ] **GL-03** `docker-push` solo en ramas `develop` y `main`
- [ ] **GL-04** Deploy staging automático en `develop`, prod `when: manual` en `main`
- [ ] **GL-05** Credenciales vienen de variables CI/CD, no hardcodeadas en el `.yml`
- [ ] **GL-06** Cache de Gradle configurada para acelerar builds sucesivos
- [ ] **GL-07** Artifacts de test reports publicados para visibilidad en MR
- [ ] **GL-08** Imagen Docker app tagged con `$CI_COMMIT_SHORT_SHA` y `latest`
- [ ] **GL-09** `Dockerfile.ci` existe y la imagen CI runner está registrada en GitLab Container Registry
- [ ] **GL-10** Pipeline regular usa `$CI_IMAGE` (imagen CI runner) en jobs `build` y `test`
- [ ] **GL-11** Pipeline separado `.gitlab-ci-image.yml` con `when: manual` y trigger en cambios de `Dockerfile.ci`, usando **Kaniko** (no DinD)
- [ ] **GL-11b** Jobs `docker-build` usan Kaniko (`gcr.io/kaniko-project/executor`) — sin `docker:24-dind` (incompatible con runners Kubernetes)
- [ ] **GL-12** Deploy staging usa `oc set image` + `oc rollout status` en OpenShift
- [ ] **GL-13** Deploy prod usa `gcloud run deploy` con `--allow-unauthenticated=false`
- [ ] **GL-14** `OC_TOKEN` y `GCP_SA_KEY` configurados como variables Protected + Masked
- [ ] **GL-15** `docker-compose.yml` disponible para testing en local sin registry

---

## Outputs esperados

- `.gitlab-ci-image.yml` para construir la imagen CI runner (una sola vez).
- `.gitlab-ci.yml` con los 5 stages; jobs `build` y `test` usan `$CI_IMAGE`.
- `Dockerfile.ci` para la imagen CI runner (JDK 21 + Gradle + dependencias).
- `Dockerfile` multi-stage para la imagen de aplicación (usa `ARG CI_IMAGE`).
- `docker-compose.yml` para testing local.
- Variables CI/CD documentadas (nombres, no valores).
