# Why

<!--
Please describe why you are proposing this code change. This should include
at least a single text paragraph. When possible formulate this from the
perspective of the product team.
-->

# What

<!--
Please explain what you did. For small/trivial changes a single paragraph is
probably sufficient. For any larger changes this should include design
choices.
-->

# References

<!-- Please include links to other artifacts related to this code change. -->

- [Story / Card](https://example.com)
- [Support Case](https://example.com)
- [Documentation card or PR](https://example.com)
- [Release note PR](https://example.com)
- [iOS agent version or PR](https://example.com)
- [android agent version or PR](https://example.com)

# Checklist

<!-- Please tick of these checklist items if applicable (or remove if not applicable). -->

- A new version of agent?
  - [ ] Add this feature into CHANGELOG.md
  - [ ] Increase version in pubspec.yaml
  - [ ] Tag main branch with new version after the PR is merged
- API change?
  - [ ] API Documentation is updated in flutter agent API page
- Native agent uplifted?
  - [ ] dependant Android agent is published to maven
  - [ ] iOS agent is published to github.com and cocoapod
- Test is needed?
  - [ ] Unit test case is applied to cover code change
- Documentation needs an update?
  - [ ] Docs PR is created and linked in references

# Merge Guidance

❗ Please use a **squash merge** unless there is an explicit reason you need to use a different merge strategy (e.g. you are bringing in changes from a previous release branch, or you have specific changes in your branch that you would like to retain). This keeps our commit history clean, makes changes more atomic, and makes it easier to revert changes.

<img width="357" alt="Screen Shot 2023-06-14 at 10 14 56 AM" src="https://media.github.ibm.com/user/365791/files/a8ee10ca-527e-4ad7-8bb9-b366509a8026">

