-- Harden private ingestion/staging tables; client grants remain absent.
alter table private.source_cells enable row level security;
alter table private.source_terms enable row level security;
alter table private.step7_fact_stage enable row level security;
alter table private.step7_rejections enable row level security;
