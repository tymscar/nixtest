# Nix with private NPM repositories

This repository is a **minimal working example** that shows how to:

* use a private NPM registry (Verdaccio in this case) from a Yarn-Berry project,
* keep the registry credentials encrypted with `git-crypt`,
* build the project with Nix **purely** (no environment variables, no network access in the final build),
* drive the same process in GitHub Actions CI.

The trick is a two–stage build:

1. A *fixed-output derivation* (`yarnOfflineCache`) is allowed to reach the network once and download all dependencies into an offline cache.
2. The real build consumes that cache inside the sandbox; the result is fully reproducible.

Everything you need—flake, lockfile, workflow and `.gitattributes`—is already committed, so you can clone the repo and run `nix build`. Just make sure to add your own private repository/package. I have taken down the Verdaccio instance I used for testing, so you will need to set up your own.

For more information read the accompanying blog post:  
https://blog.tymscar.com/posts/nixprivatenpmrepos