# limit-total-secret-ids

This exmaple Sentinel policy restricts the total number of Secret IDs for a
given AppRole to the value of `max_secret_ids`.

Sentinel authenticates to Vault using an AppRole with 10-second token TTLs.
Once the number of Secret IDs is equal to the configured threshold, further
requests for Secret ID creation will be denied.
