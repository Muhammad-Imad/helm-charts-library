# Pull Request

## Summary

<!-- What does this change and why? -->

## Affected charts

- [ ] `common` (library)
- [ ] `web-service`
- [ ] `worker`

## Checklist

- [ ] Bumped `version:` in the affected chart's `Chart.yaml` (SemVer). The
      release pipeline only publishes new versions.
- [ ] For `common` changes: bumped `version:` and the `common` dependency range
      in any consuming chart that needs the new behaviour.
- [ ] Updated `values.yaml` comments and `values.schema.json` for new/changed values.
- [ ] Ran `make lint test template` locally and they pass.
- [ ] Regenerated README tables (`make docs`) if values changed.
- [ ] Updated the chart README if behaviour or defaults changed.

## Breaking changes

<!-- Describe any breaking changes and the migration path, or write "None". -->
