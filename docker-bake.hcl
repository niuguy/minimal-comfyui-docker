variable "REGISTRY" {
    default = "ghcr.io"
}

variable "REGISTRY_USER" {
    default = "niuguy"
}

variable "APP" {
    default = "comfyui-minimal"
}

variable "RELEASE" {
    default = "v0.3.47"
}

group "default" {
    targets = ["latest"]
}

group "all" {
    targets = ["latest", "cuda124", "cuda128"]
}

target "latest" {
    dockerfile = "Dockerfile"
    tags = [
        "${REGISTRY}/${REGISTRY_USER}/${APP}:latest",
        "${REGISTRY}/${REGISTRY_USER}/${APP}:${RELEASE}"
    ]
    args = {
        COMFYUI_VERSION = "${RELEASE}"
    }
    platforms = ["linux/amd64"]
}

target "cuda124" {
    dockerfile = "Dockerfile"
    tags = ["${REGISTRY}/${REGISTRY_USER}/${APP}:cuda124-${RELEASE}"]
    args = {
        COMFYUI_VERSION = "${RELEASE}"
        CUDA_VERSION = "12.4.1"
    }
    platforms = ["linux/amd64"]
}

target "cuda128" {
    dockerfile = "Dockerfile"
    tags = ["${REGISTRY}/${REGISTRY_USER}/${APP}:cuda128-${RELEASE}"]
    args = {
        COMFYUI_VERSION = "${RELEASE}"
        CUDA_VERSION = "12.8.1"
    }
    platforms = ["linux/amd64"]
}