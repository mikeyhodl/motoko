## Nix setup

The Motoko build system relies on [Nix](https://nixos.org/) to manage
dependencies, drive the build and run the test suite. You should install `nix` by
running, as a normal user with `sudo` permissions,
```
sh <(curl -L https://nixos.org/nix/install) --daemon
```

This repository is also a Nix Flake which means you need to
allow this feature by making sure the following is present in `/etc/nix/nix.conf`:
```
extra-experimental-features = nix-command flakes
```

You should also enable a nix cache to get all dependencies pre-built.

The `cachix` command also requires `sudo` permissions.
```
nix profile install --accept-flake-config nixpkgs#cachix
cachix use ic-hs-test
```
Technically, this is optional, but without this you will build lots of build
dependencies manually, which can take several hours.

## Installation using Nix

If you want just to _use_ `moc`, you can install the `moc` binary into your `nix`
environment by running
```
$ nix profile install .#release.moc
```
in a check-out of the `motoko` repository.

### Other tools

Similarly the other tools can be installed using
```
$ nix profile install .#release.mo-doc
```
etc.

## Development using Nix

To enter a shell with the necessary dependencies available,
either run:

```
$ nix develop
```

Or use `direnv` by:

* Installing: [direnv](https://direnv.net/).

* Installing: [nix-direnv](https://github.com/nix-community/nix-direnv).

* `cd` to this directory.

* `direnv allow` (only needs to be done once).

Then all tools to develop Motoko will be loaded automatically everytime you `cd`
to this directory or everytime you update `flake.{nix,lock}`.

(The first shell start may take several minutes, afterwards being much faster.)

Within this shell you can run
 * `make` in `src/` to build all binaries,
 * `make moc` in `src/` to build just the `moc` binary,
 * `make DUNE_OPTS=--watch moc` to keep rebuilding as source files are changing
 * `make` in `rts/` to build the Motoko runtime
 * `make` in `test/` to run the test suite.

This invokes `dune` under the hood, which will, as a side effect, also create
`.merlin` files for integration with Merlin, the Ocaml Language Server

## Replicating CI locally

A good way to check that everything is fine, i.e. if this will pass CI, is to run
```
$ nix build --no-link
```

For more details on our CI and CI setup, see `CI.md`.


## Making releases

We make frequent releases, at least weekly. The steps to make a release (say, version 0.14.1) are:

Before starting the release process, ensure you are working with the latest version of the codebase. Run the following commands:

```bash
git switch master
git pull
```

Make sure the markdown doc for base is up-to-date:
For now, in a nix shell `$ nix develop` (or _re-enter_ if you already have one open):

```bash
  make -C rts
  make -C src
  make -C doc base
  git diff
```

If not, create and merge a separate PR to update the doc (adding any new files) and goto step 0.

### 1. Update Changelog

Check the recent changes from the last release:
```bash
git log --first-parent $(git describe --tags --abbrev=0)..HEAD
```
Or, on macOS, in a browser:
```bash
open "https://github.com/dfinity/motoko/compare/$(git describe --tags --abbrev=0)...master"
```

Look at changes and check that everything relevant is mentioned in the changelog section,
and possibly clean it up a bit, curating the information for the target audience.

You can get the latest released version with:

```bash
git describe --tags --abbrev=0
```

Make sure that the very top of `Changelog.md` **exactly** matches the following format (otherwise the release extraction script will fail):

```markdown
# Motoko compiler changelog

## X.Y.Z (YYYY-MM-DD)

...changelog content for this version...

## ...previous version...
```

### 2. Open a release PR

Define a shell variable `MOC_MINOR` with the next minor version number.
E.g. `export MOC_MINOR=1`, or automatically (make sure it is correct!):

```bash
export MOC_MINOR=$(($(git describe --tags --abbrev=0 | awk -F. '{print $3}') + 1))
echo MOC_MINOR=$MOC_MINOR
```

Switch to a new release branch (creating it if it doesn't exist):

```bash
git switch -c $USER/0.14.$MOC_MINOR
```

Commit the changes with exactly the following message:

```bash
git add Changelog.md
git commit -m "chore: Releasing 0.14."$MOC_MINOR
```

Push the branch:

```bash
git push --set-upstream origin $USER/0.14.$MOC_MINOR
```

Create a PR from this commit:
- Make sure the **PR title** is the same as the **commit message**.
- Label the PR with `release` (to mark it as a release PR) and `automerge-squash`. Mergify will merge it into `master` without additional approval, but it will take some time as the title (version number) enters into the `nix` dependency tracking.

To create the PR, you can use `gh` CLI:
```bash
gh pr create --title "chore: Releasing 0.14."$MOC_MINOR --label "release,automerge-squash" --base master --head $USER/0.14.$MOC_MINOR --body ""
```

After the PR is merged, the `release-pr.yml` workflow should automatically create a tag and push it to the remote repository starting the release process.

### 3. Wait for the release to complete, and verify it

Verify that the release is complete and go to the next step if the release was successful.
Otherwise, fix the issue and push the tags manually as described below:

<details>
<summary>Click here for manual tag-pushing steps if the automated release fails.</summary>

After the PR is merged: Pull the latest `master` and verify you are at the right commit:

```bash
git switch master; git pull --rebase
git show
```

Push the tag:

```bash
git tag 0.14.$MOC_MINOR -m "Motoko 0.14."$MOC_MINOR
git push origin 0.14.$MOC_MINOR
```

Pushing the tag should cause GitHub Actions to create a "Release" on the GitHub
project. This will fail if the changelog is not in order (in this case, fix and
force-push the tag).  It will also fail if the nix cache did not yet contain
the build artifacts for this revision. In this case, restart the GitHub Action
on GitHub's UI.
</details>

### 4. Update `motoko-base`

After releasing the compiler you can update `motoko-base`'s `master`
branch to the `next-moc` branch.

* Wait ca. 5min after releasing to give the CI/CD pipeline time to upload the release artifacts
* Change into `motoko-base` and pull the latest `next-moc`
```bash
git switch next-moc; git pull
```
* Create a new branch for the update
```bash
git switch -c $USER/update-moc-0.14.$MOC_MINOR
```
* Revise and update the `CHANGELOG.md`, by adding a top entry for the release
* Update the `moc_version` env variable in `.github/workflows/{ci, package-set}.yml` and `mops.toml`
  to the new released version:
```bash
perl -pi -e "s/moc_version: \"0\.14\.\\d+\"/moc_version: \"0.14.$MOC_MINOR\"/g; s/moc = \"0\.14\.\\d+\"/moc = \"0.14.$MOC_MINOR\"/g; s/version = \"0\.14\.\\d+\"/version = \"0.14.$MOC_MINOR\"/g" .github/workflows/ci.yml .github/workflows/package-set.yml mops.toml
```
* Add the changed files and commit the changes
```bash
git add .github/ CHANGELOG.md mops.toml && git commit -m "Motoko 0.14."$MOC_MINOR
```
* Push the branch
```bash
git push --set-upstream origin $USER/update-moc-0.14.$MOC_MINOR
```

Make a PR off of that branch, targeting `master`, and merge it using a _normal merge_ (not
squash merge) once CI passes. It will eventually be imported into this
repo by a scheduled `niv-updater-action`.

Finally tag the base release (so the documentation interpreter can do the right thing):
First, switch to `master`, pull the latest changes and verify we are at the right commit:
```bash
git switch master && git pull
git show
```
* Tag and push the release
```bash
git tag moc-0.14.$MOC_MINOR
git push origin moc-0.14.$MOC_MINOR
```

### Downstream

There are a few dependent actions to follow-up the release, e.g.
- `motoko` NPM package
- `vessel` package set
- `vscode` plugin
- ICP Ninja

These are generally triggered by mentioning the release in Slack.

Announcing the release towards SDK happens by triggering this GitHub action:
https://github.com/dfinity/sdk/actions/workflows/update-motoko.yml
Press the "Run workflow" button, filling in
- Motoko version: `latest`
- Open PR against this sdk branch: `master`

and then hitting the green button. This will create a PR with all necessary hash changes against that branch. There is no
need to do this immediately, you can leave the release soaking a few days. Use your own jugdement w.r.t. risk, urgency etc.

If you want to update the portal documentation, typically to keep in sync with a `dfx` release, follow the instructions in https://github.com/dfinity/portal/blob/master/MAINTENANCE.md.

## Coverage report

To build with coverage enabled, compile the binaries in `src/` with
```
make DUNE_OPTS="--instrument-with bisect_ppx"`
```
and then use `bisect-ppx-report html` to produce a report.

The full report can be built with
```
nix build .#tests.coverage
```
and the report for latest `master` can be viewed at
[https://dfinity.github.io/motoko/coverage/](https://dfinity.github.io/motoko/coverage/).

## Profile the compiler

(This section is currently defunct, and needs to be update to work with the dune
build system.)

1. Build with profiling within nix-shell (TODO: How to do with dune)
   ```
   make -C src clean
   make BUILD=p.native -C src moc
   ```
2. Run `moc` as normal, e.g.
   ```
   moc -g -c foo.mo -o foo.wasm
   ```
   this should dump a `gmon.out` file in the current directory.
3. Create the report, e.g. using
   ```
   gprof --graph src/moc
   ```
   (Note that you have to _run_ this in the directory with `gmon.out`, but
   _pass_ it the path to the binary.)


## Benchmarking the RTS

Specifically some advanced techniques to obtain performance deltas for the
GC can be found in `rts/Benchmarking.md`.
