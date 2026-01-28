# Load .env (buildx bake doesn't support --env-file)
set dotenv-load

# Get the current git SHA
git_sha := `git rev-parse --short HEAD 2>/dev/null || echo "unknown"`

# List available recipes
default:
    @just --list

# Build Docker image with git SHA for AMD64 and ARM64 platforms
build:
    GIT_SHA={{git_sha}} docker buildx bake

# Build Docker image for ARM64 only
build-arm:
    GIT_SHA={{git_sha}} docker buildx bake --set '*.platform=linux/arm64'

# Build Docker image for AMD64 only
build-amd:
    GIT_SHA={{git_sha}} docker buildx bake --set '*.platform=linux/amd64'

push:
    GIT_SHA={{git_sha}} docker buildx bake --push

# Deploy to Dokku using SHA-tagged image
deploy:
    dokku git:from-image $IMAGE_NAME:{{git_sha}}

# Build, and deploy
release: build push deploy

# Debug: print variable values
debug:
    @echo "Variables:"
    @echo "  git_sha: {{git_sha}}"
    @echo "  IMAGE_NAME: $IMAGE_NAME"
    @echo ""
    @echo "build command:"
    @echo "  GIT_SHA={{git_sha}} docker buildx bake"
    @echo ""
    @echo "push command:"
    @echo "  GIT_SHA={{git_sha}} docker buildx bake --push"
    @echo ""
    @echo "deploy command:"
    @echo "  dokku git:from-image $IMAGE_NAME:{{git_sha}}"
