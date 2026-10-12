locals {
  image_name   = "${var.instance_name}-nixos-uefi"
  image_object = "${var.instance_name}-nixos.qcow2"
}

data "oci_objectstorage_namespace" "this" {}

# The image's derivation path is its identity: any change to the host's
# configuration moves it, and that is the only thing that should rebuild the
# image. A plan that changes nothing else is a no-op.
data "external" "image" {
  program = [
    "bash",
    "-c",
    "printf '{\"drv\":\"%s\"}' \"$(nix eval --raw ${path.module}/../../..#nixosConfigurations.heimdall.config.system.build.images.oci.drvPath)\"",
  ]
}

# The qcow2's way in: OCI imports an image from an object, never from a file.
# Nothing reads the bucket afterwards, so it lives exactly as long as the
# upload does.
resource "oci_objectstorage_bucket" "image" {
  compartment_id = var.compartment_id
  namespace      = data.oci_objectstorage_namespace.this.namespace
  name           = "${var.instance_name}-images"
  access_type    = "NoPublicAccess"
  storage_tier   = "Standard"
  freeform_tags  = { managed_by = "opentofu" }
}

# nix builds the qcow2, the CLI uploads it. The derivation path is the trigger,
# so an unchanged host rebuilds nothing and the upload runs once per image.
resource "terraform_data" "image" {
  triggers_replace = {
    drv    = data.external.image.result.drv
    bucket = oci_objectstorage_bucket.image.name
    object = local.image_object
  }

  provisioner "local-exec" {
    command = "set -eu; out=$(nix build --no-link --print-out-paths ${path.module}/../../..#nixosConfigurations.heimdall.config.system.build.images.oci); qcow2=$(find -L \"$out\" -maxdepth 1 -type f -name '*.qcow2' -print -quit); nix run nixpkgs#oci-cli -- os object put --bucket-name ${oci_objectstorage_bucket.image.name} --name ${local.image_object} --file \"$qcow2\" --force"
  }

  # A bucket cannot be deleted while an object is in it.
  provisioner "local-exec" {
    when    = destroy
    command = "nix run nixpkgs#oci-cli -- os object delete --bucket-name ${self.triggers_replace.bucket} --name ${self.triggers_replace.object} --force || true"
  }
}

# One image, replaced when the host's configuration moves. The live instance is
# untouched by that — source_details is in its ignore_changes — so a new image
# is adopted by the next instance that is deliberately created.
resource "oci_core_image" "nixos" {
  compartment_id = var.compartment_id
  display_name   = local.image_name
  launch_mode    = "PARAVIRTUALIZED"
  freeform_tags  = { managed_by = "opentofu" }

  image_source_details {
    source_type              = "objectStorageTuple"
    namespace_name           = data.oci_objectstorage_namespace.this.namespace
    bucket_name              = oci_objectstorage_bucket.image.name
    object_name              = local.image_object
    source_image_type        = "QCOW2"
    operating_system         = "NixOS"
    operating_system_version = "26.11"
  }

  # OCI reads the 24 GB object back and rewrites it: 10-20 minutes, well past
  # the provider's default patience.
  timeouts {
    create = "90m"
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [terraform_data.image]
}
