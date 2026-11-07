data "oci_identity_availability_domains" "this" {
  compartment_id = var.compartment_id
}

# The subnet is the tenancy's (../ — the network stack one level up), created
# once for every host that will ever live in this VCN. This stack only reads it.
data "terraform_remote_state" "network" {
  backend = "local"

  config = {
    path = "${path.module}/../terraform.tfstate"
  }
}

# Nothing on this host is addressed by its network location: the VM's own IP,
# the boot volume's OCID and the data volume all change or move across a
# rebuild, and the DNS record is the only thing that has to be told.
resource "oci_core_instance" "heimdall" {
  compartment_id      = var.compartment_id
  availability_domain = data.oci_identity_availability_domains.this.availability_domains[var.availability_domain_index].name
  display_name        = var.instance_name
  shape               = "VM.Standard.A1.Flex"

  shape_config {
    ocpus         = 2
    memory_in_gbs = 12
  }

  # UEFI to match the image's GPT/ESP disk, and paravirtualized is this shape's
  # only network path. OCI cannot change the firmware after launch, so this is
  # worth being explicit about.
  launch_options {
    firmware = "UEFI_64"

    # Omitting this alongside launch_options is a 400 — and paravirtualized is
    # the only network path this shape's VNIC offers anyway.
    network_type = "PARAVIRTUALIZED"
  }

  source_details {
    source_type = "image"
    source_id   = oci_core_image.nixos.id

    # 200 GB is the whole Always Free block-storage allowance and this tenancy
    # has no other volume, so the boot volume is born at the limit instead of
    # grown later — OCI volumes cannot shrink. The image itself is 24 GB;
    # boot.growPartition and the ext4 root's autoResize finish the job.
    boot_volume_size_in_gbs = 200
  }

  create_vnic_details {
    subnet_id        = data.terraform_remote_state.network.outputs.subnet_id
    assign_public_ip = true
    hostname_label   = var.instance_name
  }

  metadata = {
    ssh_authorized_keys = join("\n", var.ssh_authorized_keys)
  }

  # Terminating the instance takes the disk with it, which is the point: a
  # rebuild is a clean install, not a restore. headscale's database and node
  # key live there, so a rebuild re-issues them and the tailnet re-authenticates
  # — that is the deliberate path, and `just oci-destroy` is the only one that
  # reaches it.
  preserve_boot_volume = var.preserve_boot_volume

  freeform_tags = {
    managed_by = "opentofu"
  }

  lifecycle {
    prevent_destroy = var.prevent_destroy
    # Only the create path reads source_details, and an instance cannot swap
    # disks anyway; without this, a rebuilt image would plan an impossible
    # in-place change instead of the deliberate destroy-and-apply.
    #
    # create_vnic_details is here for the opposite reason: the live VNIC was
    # made with assign_public_ip false and an older hostname, and flipping it
    # would hand the host a second, ephemeral address for no gain. New
    # instances still get the public address this config asks for.
    ignore_changes = [source_details, create_vnic_details]
  }
}
