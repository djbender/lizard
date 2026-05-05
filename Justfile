# Load .env (buildx bake doesn't support --env-file)
set dotenv-load

# Get the current git SHA
git_sha := `git rev-parse --short HEAD 2>/dev/null || echo "unknown"`

# List available recipes
default:
    @just --list

# Build docker compose dev image
verify:
    docker compose build

# Build Docker image with git SHA for AMD64 and ARM64 platforms
build:
    GIT_SHA={{git_sha}} docker buildx bake --file docker-bake.hcl

# Build Docker image for ARM64 only
build-arm:
    GIT_SHA={{git_sha}} docker buildx bake --file docker-bake.hcl --set '*.platform=linux/arm64'

# Build Docker image for AMD64 only
build-amd:
    GIT_SHA={{git_sha}} docker buildx bake --file docker-bake.hcl --set '*.platform=linux/amd64'

push:
    GIT_SHA={{git_sha}} docker buildx bake --file docker-bake.hcl --push

# Deploys are handled by GitHub Actions
deploy:
    @echo "Deploys are handled by GitHub Actions, not the Justfile. See .github/workflows/." >&2
    @exit 1

# Releases are handled by GitHub Actions
release:
    @echo "Releases are handled by GitHub Actions, not the Justfile. See .github/workflows/." >&2
    @exit 1

# Debug: print variable values
debug:
    @echo "Variables:"
    @echo "  git_sha: {{git_sha}}"
    @echo "  IMAGE_NAME: $IMAGE_NAME"
    @echo ""
    @echo "build command:"
    @echo "  GIT_SHA={{git_sha}} docker buildx bake --file docker-bake.hcl"
    @echo ""
    @echo "push command:"
    @echo "  GIT_SHA={{git_sha}} docker buildx bake --file docker-bake.hcl --push"
