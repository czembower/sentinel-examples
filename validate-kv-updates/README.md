# validate-kv-updates

This exmaple Sentinel policy rejects all updates (POST or PATCH requests) to
the specifed KV engine that attempt to overwrite existing values in KV pairs,
forcing clients to write unique data.

Sentinel authenticates to Vault using an AppRole with 10-second token TTLs.
