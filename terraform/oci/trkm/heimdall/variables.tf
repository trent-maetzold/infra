variable "compartment_id" {
  description = "Root compartment — this tenancy."
  type        = string
  default     = "ocid1.tenancy.oc1..aaaaaaaa6srwkcjh57qz6ig3gyqhqsxrhebcjvcpadiafcnaj2eofwtrrmna"
}

variable "availability_domain_index" {
  description = "Which AD to launch in (0..2). The A1 capacity lottery is per-AD, so try the others when it has none."
  type        = number
  default     = 0
}

variable "instance_name" {
  description = "Name for the instance, its host and its display name everywhere in the console. Override it for a throwaway."
  type        = string
  default     = "heimdall"
}

variable "prevent_destroy" {
  description = "Guard on the instance: a stray destroy cannot plan its replacement. `just oci-destroy` passes false, which is the deliberate path."
  type        = bool
  default     = true
}

variable "preserve_boot_volume" {
  description = "Keep the disk when the instance goes away. Off, so a rebuild boots a fresh disk — the image is the whole machine and the disk is where headscale's database lives. On carries the disk across a replacement."
  type        = bool
  default     = false
}

variable "ssh_authorized_keys" {
  description = "Merged into instance metadata (ssh_authorized_keys), which OCI treats as force-new: this has to stay byte-identical to what the instance already carries or a plan wants to replace it."
  type        = list(string)
  default     = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMZMIGNBlZ+VX528eFfwCmEuN4oQCigRA+FPwADzixds tm@default"]
}
