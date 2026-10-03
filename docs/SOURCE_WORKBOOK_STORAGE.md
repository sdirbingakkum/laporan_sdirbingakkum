# Original XLSX Source Layer

Step 9C adds a private original-workbook access layer for Commander provenance.

Applied Supabase migration: `20261003201038_add_original_source_workbook_file_layer`.

## Data model

`public.source_report_files` links one imported `source_reports` row to its original XLSX object metadata:

- `bucket_id`: `source-workbooks`
- `object_path`: private storage object path
- `original_filename`
- `content_type`
- `byte_size`
- `file_sha256`
- `availability_status`: `MISSING`, `AVAILABLE`, or `RETIRED`
- `access_scope`: currently `ALL_POMDAM_SHARED`

The table is RLS-enabled and has no client SELECT policy. File metadata is exposed only through the Commander source-file RPC.

## Access contract

The bucket `source-workbooks` is private and accepts only XLSX MIME type with a 100 MiB object limit.

Storage SELECT is allowed only when:

1. the user is authenticated;
2. the user has `VIEW_COMMANDER_COP`;
3. the file metadata is `AVAILABLE`;
4. the file is marked `ALL_POMDAM_SHARED`;
5. the user has an `ALL_POMDAM` role scope.

This intentionally prevents a Pomdam-scoped account from downloading a shared workbook that may contain another Pomdam's cells.

The Flutter app obtains file metadata through `get_commander_source_file_context`, then requests a 5-minute signed URL for the exact private object. The app opens the original XLSX without routing it through a third-party document viewer.

## Current data state

The existing source lineage contains imported cell snapshots, but no original XLSX objects have been registered in `source_report_files` yet. Therefore the UI reports `FILE NOT AVAILABLE` until the corresponding original file is uploaded and registered with the matching source report.

The imported-cell source-sheet inspector remains the authoritative fallback for the current dataset; it is explicitly not an XLSX renderer.
