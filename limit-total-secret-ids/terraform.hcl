resource "vault_auth_backend" "approle" {
  type      = "approle"
  path      = "approle"
}

resource "vault_approle_auth_backend_role" "sentinel_secret_id" {
  backend                 = vault_auth_backend.approle.path
  role_name               = vault_policy.sentinel_secret_id.name
  token_policies          = [vault_policy.sentinel_secret_id.name]
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

resource "vault_approle_auth_backend_role_secret_id" "sentinel_secret_id" {
  backend   = vault_auth_backend.approle.path
  role_name = vault_approle_auth_backend_role.sentinel_secret_id.role_name

  metadata = jsonencode(
    {
      "sentinel" = "true"
    }
  )
}

resource "vault_policy" "sentinel_secret_id" {
  name      = "sentinel-secret-id"

  policy = <<EOT
path "auth/approle/*" {
  capabilities = ["read", "list"]
}
EOT
}

resource "vault_egp_policy" "secret_id" {
  name              = "secret_id"
  paths             = ["auth/${vault_auth_backend.approle.path}/role/*"]
  enforcement_level = "hard-mandatory"

  policy = templatefile(
    "${path.module}/secret-id.sentinel",
    {
      vault_addr     = "http://127.0.0.1:8200"
      role_id        = vault_approle_auth_backend_role.sentinel_secret_id.role_id
      secret_id      = vault_approle_auth_backend_role_secret_id.sentinel_secret_id.secret_id
      max_secret_ids = 100
    }
  )
}