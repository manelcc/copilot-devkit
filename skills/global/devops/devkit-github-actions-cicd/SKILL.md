---
name: "devkit-github-actions-cicd"
description: >
  Genera y valida workflows GitHub Actions cross-stack: Kotlin/Ktor, Python FastAPI, Android, iOS.
  Modelo dos imágenes Docker (CI runner una sola vez + app por push), jobs build/test/docker-build/docker-push/deploy,
  GitHub Container Registry (GHCR), staging automático en OpenShift y producción en Google Cloud Run con aprobación manual.
applyTo:
  - ".github/workflows/*.yml"
  - "Dockerfile"
triggers:
  - "crea el pipeline de github"
  - "configura github actions"
  - "genera el workflow de github"
  - "pipeline para github actions"
  - "github container registry"
  - "ghcr"
  - "workflow de github"
  - "github actions para android"
  - "github actions para ios"
  - "github actions para python"
nonTriggers:
  - Pipeline de GitLab CI (usar devkit-gitlab-cicd)
  - Pipeline de Azure DevOps (usar devkit-azure-pipelines-cicd)
  - Implementación de código (usar el stack expert correspondiente)
governance: devkit-devops
scope: global
---

# GitHub Actions CI/CD

## Purpose

Genera workflows GitHub Actions completos para el proyecto MCP Server ShareResources:
build Gradle, tests con JaCoCo, Docker multi-stage, publicación en GitHub Container
Registry (GHCR), deploy staging en **OpenShift** y prod en **Google Cloud Run** con aprobación manual.


## When to use
- User asks to set up CI/CD for a GitHub Actions project
- User needs to generate or update `.github/workflows/ci.yml`
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

| Imagen | Fichero | Cuándo se construye | Tag en GHCR | Propósito |
|---|---|---|---|---|
| **CI Runner** | `Dockerfile.ci` | **Una sola vez** al crear el repo; si cambia `Dockerfile.ci` | `ghcr.io/<repo>/ci-runner:latest` | Base de todos los jobs CI/CD. JDK 21 + Gradle + dependencias pre-cacheadas |
| **Aplicación** | `Dockerfile` | En cada push a `develop` o `main` | `ghcr.io/<repo>:$SHA` | Imagen del MCP server. Se despliega en local, OpenShift y Cloud Run |

---

## Dockerfile.ci — Imagen CI Runner (construir UNA sola vez)

```dockerfile
# Dockerfile.ci — CI Runner: JDK 21 + Gradle + dependencias pre-cacheadas
# Registrar en GHCR al crear el repositorio (ver workflow ci-image.yml).
# Actualizar solo si cambian las dependencias Gradle o la versión de JDK.
FROM eclipse-temurin:21-jdk-alpine
WORKDIR /ci-workspace
COPY gradle/ gradle/
COPY gradlew ./
COPY build.gradle.kts settings.gradle.kts ./
RUN chmod +x ./gradlew && \
    ./gradlew dependencies --no-daemon --quiet 2>/dev/null || true
```

## Workflow ci-image.yml — Construir la imagen CI Runner (UNA VEZ por repo)

```yaml
# .github/workflows/ci-image.yml
# Ejecutar manualmente al crear el repo o automáticamente cuando cambia Dockerfile.ci
name: Build CI Runner Image

on:
  workflow_dispatch:
  push:
    paths:
      - 'Dockerfile.ci'
    branches: [develop, main]

env:
  REGISTRY:      ghcr.io
  CI_IMAGE_NAME: ${{ github.repository }}/ci-runner

jobs:
  build-ci-image:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write
    steps:
      - uses: actions/checkout@v4

      - name: Log in to GHCR
        uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Build and push CI runner image
        uses: docker/build-push-action@v5
        with:
          context: .
          file: Dockerfile.ci
          push: true
          tags: |
            ${{ env.REGISTRY }}/${{ env.CI_IMAGE_NAME }}:latest
            ${{ env.REGISTRY }}/${{ env.CI_IMAGE_NAME }}:${{ github.sha }}
```

## Dockerfile — Imagen de aplicación (construir en cada push)

```dockerfile
# Dockerfile — Imagen del MCP server
# ARG CI_IMAGE: imagen CI runner del registry (Gradle + dependencias cacheadas)
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

## Workflow principal: ci.yml

```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [develop, main]
  pull_request:
    branches: [develop, main]

env:
  REGISTRY:      ghcr.io
  IMAGE_NAME:    ${{ github.repository }}
  CI_IMAGE:      ghcr.io/${{ github.repository }}/ci-runner:latest  # Imagen CI runner (construida una sola vez)

jobs:
  # ── Job: build (usa imagen CI runner del registry) ────────────────────────
  build:
    runs-on: ubuntu-latest
    container:
      image: ${{ env.CI_IMAGE }}
      credentials:
        username: ${{ github.actor }}
        password: ${{ secrets.GITHUB_TOKEN }}
    steps:
      - uses: actions/checkout@v4

      - name: Cache Gradle
        uses: actions/cache@v4
        with:
          path: ~/.gradle/caches
          key: ${{ runner.os }}-gradle-${{ hashFiles('**/*.gradle.kts') }}
          restore-keys: ${{ runner.os }}-gradle-

      - name: Build
        run: ./gradlew assemble --no-daemon

      - name: Upload build artifacts
        uses: actions/upload-artifact@v4
        with:
          name: build-libs
          path: build/libs/
          retention-days: 1

  # ── Job: test (usa imagen CI runner + servicio postgres) ──────────────────
  test:
    runs-on: ubuntu-latest
    needs: build
    container:
      image: ${{ env.CI_IMAGE }}
      credentials:
        username: ${{ github.actor }}
        password: ${{ secrets.GITHUB_TOKEN }}
    services:
      postgres:
        image: postgres:15-alpine
        env:
          POSTGRES_DB:       mcp_test
          POSTGRES_USER:     mcp
          POSTGRES_PASSWORD: mcp_secret
        ports:
          - 5432:5432
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
    env:
      DB_URL:      jdbc:postgresql://postgres:5432/mcp_test
      DB_USER:     mcp
      DB_PASSWORD: mcp_secret
    steps:
      - uses: actions/checkout@v4

      - name: Cache Gradle
        uses: actions/cache@v4
        with:
          path: ~/.gradle/caches
          key: ${{ runner.os }}-gradle-${{ hashFiles('**/*.gradle.kts') }}

      - name: Test + Coverage
        run: ./gradlew test jacocoTestReport jacocoTestCoverageVerification --no-daemon

      - name: Publish test results
        uses: EnricoMi/publish-unit-test-result-action@v2
        if: always()
        with:
          files: build/test-results/test/TEST-*.xml

      - name: Upload JaCoCo report
        uses: actions/upload-artifact@v4
        with:
          name: jacoco-report
          path: build/reports/jacoco/

  # ── Job: docker-build (imagen de aplicación) ──────────────────────────────
  docker-build:
    runs-on: ubuntu-latest
    needs: test
    if: github.ref == 'refs/heads/develop' || github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v4

      - name: Download build artifacts
        uses: actions/download-artifact@v4
        with:
          name: build-libs
          path: build/libs/

      - name: Build Docker app image
        run: |
          docker build \
            --build-arg CI_IMAGE=${{ env.CI_IMAGE }} \
            -t ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.sha }} \
            -t ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:latest \
            .

  # ── Job: docker-push ──────────────────────────────────────────────────────
  docker-push:
    runs-on: ubuntu-latest
    needs: docker-build
    if: github.ref == 'refs/heads/develop' || github.ref == 'refs/heads/main'
    permissions:
      contents: read
      packages: write
    steps:
      - uses: actions/checkout@v4

      - name: Log in to GHCR
        uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Build and push app image
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          build-args: CI_IMAGE=${{ env.CI_IMAGE }}
          tags: |
            ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.sha }}
            ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:latest

  # ── Job: deploy-staging → OpenShift (automático en develop) ───────────────
  deploy-staging:
    runs-on: ubuntu-latest
    needs: docker-push
    if: github.ref == 'refs/heads/develop'
    environment:
      name: staging
      url: ${{ vars.OC_STAGING_URL }}
    steps:
      - name: Install oc CLI
        run: |
          curl -fsSL https://mirror.openshift.com/pub/openshift-v4/clients/oc/latest/linux/oc.tar.gz | tar xz
          sudo mv oc /usr/local/bin/

      - name: Deploy to OpenShift staging
        run: |
          oc login ${{ vars.OC_SERVER }} \
            --token=${{ secrets.OC_TOKEN }} \
            --insecure-skip-tls-verify=false
          oc -n ${{ vars.OC_NAMESPACE_STAGING }} set image deployment/${{ vars.APP_NAME }} \
            ${{ vars.APP_NAME }}=${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.sha }}
          oc -n ${{ vars.OC_NAMESPACE_STAGING }} rollout status \
            deployment/${{ vars.APP_NAME }} --timeout=5m

  # ── Job: deploy-prod → Cloud Run (manual con aprobación en main) ──────────
  deploy-prod:
    runs-on: ubuntu-latest
    needs: docker-push
    if: github.ref == 'refs/heads/main'
    environment:
      name: production
      url: ${{ vars.CLOUD_RUN_URL }}
    steps:
      - name: Authenticate to GCP
        uses: google-github-actions/auth@v2
        with:
          credentials_json: ${{ secrets.GCP_SA_KEY }}

      - name: Deploy to Cloud Run
        uses: google-github-actions/deploy-cloudrun@v2
        with:
          service: ${{ vars.CLOUD_RUN_SERVICE }}
          image:   ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.sha }}
          region:  ${{ vars.GCP_REGION }}
          flags:   '--allow-unauthenticated=false'
```

> **Nota:** El job `deploy-prod` requiere configurar el environment `production` en GitHub con **Required reviewers** para forzar la aprobación manual.

---

## Secrets y variables en GitHub

Configurar en **Settings → Secrets and variables → Actions**:

| Nombre | Tipo | Descripción |
|---|---|---|
| `GITHUB_TOKEN` | Secret automático | Provisto por GitHub. Para GHCR y CI runner image |
| `OC_TOKEN` | Secret (`secrets.*`) | Token del service account de OpenShift |
| `GCP_SA_KEY` | Secret (`secrets.*`) | JSON del Service Account de GCP |
| `OC_SERVER` | Variable (`vars.*`) | URL del servidor OpenShift |
| `OC_NAMESPACE_STAGING` | Variable (`vars.*`) | Namespace OpenShift staging |
| `OC_STAGING_URL` | Variable (`vars.*`) | URL del entorno staging en OpenShift |
| `APP_NAME` | Variable (`vars.*`) | Nombre del deployment en OpenShift |
| `GCP_REGION` | Variable (`vars.*`) | Región de Cloud Run (ej: `europe-west1`) |
| `CLOUD_RUN_SERVICE` | Variable (`vars.*`) | Nombre del servicio Cloud Run |
| `CLOUD_RUN_URL` | Variable (`vars.*`) | URL del servicio Cloud Run (generada por GCP) |
| Secretos de DB prod | Secret (`secrets.*`) | Nunca en el workflow |

---

## Validation

- [ ] **GH-01** Jobs en orden con `needs:`: `build → test → docker-build → docker-push → deploy`
- [ ] **GH-02** Servicio `postgres` en el job `test` con health-check
- [ ] **GH-03** `docker-push` solo en `develop` y `main` (condición `if:`)
- [ ] **GH-04** Environment `production` con Required reviewers activado para aprobación manual
- [ ] **GH-05** Credenciales de DB en `env:` del job, no hardcodeadas
- [ ] **GH-06** `GITHUB_TOKEN` para GHCR con `permissions: packages: write`
- [ ] **GH-07** Cache de Gradle con clave basada en el hash de `*.gradle.kts`
- [ ] **GH-08** Imagen app tagged con `${{ github.sha }}` y `latest`
- [ ] **GH-09** `Dockerfile.ci` existe y workflow `ci-image.yml` con `workflow_dispatch` creado
- [ ] **GH-10** Jobs `build` y `test` usan `container.image` con la imagen CI runner de GHCR
- [ ] **GH-11** Deploy staging usa `oc set image` + `oc rollout status` en OpenShift
- [ ] **GH-12** Deploy prod usa action `google-github-actions/deploy-cloudrun@v2`
- [ ] **GH-13** `OC_TOKEN` y `GCP_SA_KEY` configurados como GitHub Secrets (nunca como variables)
- [ ] **GH-14** `docker-compose.yml` disponible para testing en local sin registry

---

## Expected outputs

- `.github/workflows/ci-image.yml` para construir la imagen CI runner (una sola vez).
- `.github/workflows/ci.yml` con 6 jobs; `build` y `test` usan container CI runner.
- `Dockerfile.ci` para la imagen CI runner (JDK 21 + Gradle + dependencias).
- `Dockerfile` multi-stage para la imagen de aplicación (usa `ARG CI_IMAGE`).
- `docker-compose.yml` para testing local.
- Environment `production` configurado con aprobación manual en GitHub.

## Examples
- "Set up GitLab CI for my Kotlin/Ktor service with OpenShift staging and Cloud Run prod"
- "Add GitHub Actions pipeline with GHCR registry and manual production approval"
- "Migrate my Azure DevOps pipeline to GitHub Actions"
