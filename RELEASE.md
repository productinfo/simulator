# Releasing

In this documents you'll find all the necessary steps to release a new version of `Simulator`.

> Although some of the steps have been automated, there are some of them that need to be executed manually.

1. Re-generate the Carthage project with `tuist generate` _(Install [Tuist](https://github.com/tuist/tuist) if you don't have it installed already)_.
2. Update Carthage dependencies if they are outdated with `carthage update --platform macOS`.
3. Validate the state of the project by running `make release-check`
4. Update the `CHANGELOG.md` adding a new entry at the top with the next version. Make sure that all the changes in the version that is about to be released are properly formatted. Commit the changes in `CHANGELOG.md`.
5. Update the version in the `Simulator.podspec` and `README.md` files.
6. Generate the documentation by running [this script](https://github.com/tuist/jazzy-theme).
7. Commit, tag and push the changes to GitHub.
8. Create a new release on [GitHub](https://github.com/tuist/simulator) including the information from the last entry in the `CHANGELOG.md`.
9. Run `make carthage-archive` and attach the `Simulator.framework.zip` artifact to the GitHub release.
10. Push the pods with `make pod-push`.

### Notes

- If any of the steps above is not clear above do not hesitate to propose improvements.
- Release should be done only by authorized people that have rights to crease releases in this repository and commiting changes to the Tap repository.
