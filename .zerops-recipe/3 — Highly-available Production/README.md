<!-- #ZEROPS_EXTRACT_START:intro# -->
2–4 tinbase containers behind the L7 balancer over one 3-node HA managed Postgres.
Possible because tinbase is stateless — its data lives in the managed database.
REST / Auth / Storage fan out across containers; realtime CDC across many instances
is still maturing upstream.
<!-- #ZEROPS_EXTRACT_END:intro# -->
