# validate-kv-updates

This exmaple Sentinel policy rejects all updates (POST or PATCH requests) to
the specifed KV engine that attempt to overwrite existing values in KV pairs,
forcing clients to write unique data.

Additionally, if custom_metadata for the KV secret exists, and within that
metadata there exists a key "secret_type" with a value of "password", password
complexity will be validated.

Sentinel authenticates to Vault using an AppRole with 10-second token TTLs.
