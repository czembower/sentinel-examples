resource "vault_auth_backend" "approle" {
  type      = "approle"
  path      = "approle"
}

resource "vault_approle_auth_backend_role" "sentinel_kv" {
  backend                 = vault_auth_backend.approle.path
  role_name               = vault_policy.sentinel_kv.name
  token_policies          = [vault_policy.sentinel_kv.name]
  bind_secret_id          = true
  secret_id_num_uses      = 0
  secret_id_ttl           = 0
  token_explicit_max_ttl  = 10
  token_max_ttl           = 10
  token_no_default_policy = false
  token_num_uses          = 0
  token_period            = null
  token_ttl               = 10
  token_type              = "batch"
}

resource "vault_approle_auth_backend_role_secret_id" "sentinel_kv" {
  backend   = vault_auth_backend.approle.path
  role_name = vault_approle_auth_backend_role.sentinel_kv.role_name

  metadata = jsonencode(
    {
      "sentinel" = "true"
    }
  )
}

resource "vault_policy" "sentinel_kv" {
  name = "sentinel-kv"

  policy = <<EOT
path "kv/*" {
  capabilities = ["read"]
}
EOT
}

resource "vault_egp_policy" "kv" {
  name              = "kv"
  paths             = ["kv/*"]
  enforcement_level = "hard-mandatory"

  policy = templatefile(
    "${path.module}/kv-validate.sentinel",
    {
      vault_addr         = "http://127.0.0.1:8200"
      role_id            = vault_approle_auth_backend_role.sentinel_kv.role_id
      secret_id          = vault_approle_auth_backend_role_secret_id.sentinel_kv.secret_id
      approle_mount_path = vault_auth_backend.approle.path
    }
  )
}
