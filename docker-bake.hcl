# Get the current git SHA
variable "GIT_SHA" {
  default = ""
}

# Docker image base name
variable "IMAGE_NAME" {
  default = "registry.dokku.djbender.com/lizard"
}

# Default target for building multiple platforms
target "default" {
  platforms = ["linux/amd64", "linux/arm64"]
  tags = [
    "${IMAGE_NAME}:${GIT_SHA}",
    "${IMAGE_NAME}:latest"
  ]
  args = {
    GIT_SHA = "${GIT_SHA}"
  }
}
