# Release process

1. Update the `MARKETING_VERSION` in each module.
2. Update the `CHANGELOG.md`.
3. Run `ruby scripts/build.rb NEW_VERSION_HERE`.
4. Push the generated changes to the repo.
5. Upload the contents of `.build/outputs` to the CDN.
6. Create a GitHub release with the contents of the `CHANGELOG.md`.
