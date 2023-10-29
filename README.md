# Multi-purpose XBPS container images

This branch aims to provide container images which are able to build binary packages for [Void Linux](https://voidlinux.org) which can be installed using [XBPS](https://docs.voidlinux.org/xbps/index.html).

The main focus of these images is executing `xbps-src` from [void-linux/void-packages](https://github.com/void-linux/void-packages) in CI environments.

Currently, only the `glibc` variants are available. `musl` will be added if needed in the future.

## Architectures

The image is built for multiple Void Linux architectures, including:
  - `x86_64`
  - `i686`
  - `aarch64`

They are published as [`ghcr.io/xdeb-org/voidlinux-repository:<arch>`](https://ghcr.io/xdeb-org/voidlinux-repository).

**Note**: The specific images of this branch are created with CI environments in mind, without any user interaction. It is discouraged to manually use them as described in [How to use manually](#how-to-use-manually). They will mess up file permissions on the `void-packages` directory besides other things.

## How to use in CI environments

First, make sure to have a build script at your disposal. For this script to work, keep the following things in mind:
  1. Think of a directory within the container environment to work with your checked out Git project: I opted for<br/>`/workspace`
  2. Make sure that `void-packages` is available and checked out within `<directory of step 1>`:<br/>`/workspace/void-packages` (see below)
  3. Make sure that the script marks `/workspace/void-packages` as safe for use with Git *before* working with `xbps-src`:<br/>`git config --global --add safe.directory /workspace/void-packages`
  4. Make sure to change into the `void-packages` directory *before* working with `xbps-src`:<br/>`cd /workspace/void-packages`
  5. Satisfy `xbps-src` by linking the container's root FS to `/workspace/void-packages/masterdir`, which tells `xbps-src` not to create a chroot environment:<br/>`ln -s / masterdir`
  6. Make sure `/workspace/void-packages/srcpkgs` contains the packages you want to build. How you accomplish that is up to you.

Note: Executing `./xbps-src binary-bootstrap` from within the directory `/workspace/void-packages` has no effect. Don't do it.

An example of a build script (step 1) could be:
```bash
#!/bin/bash

git config --global --add safe.directory /workspace/void-packages

cd /workspace/void-packages
ln -s / masterdir

# execute ./xbps-src commands
# execute xtools commands
```

After build, XBPS packages are going to be available at `/workspace/void-packages/hostdir/binpkgs`.

In order to use this image in CI environments, you will have to get the `void-packages` somehow, either clone it or add it as a submodule to your project. Submodules work much faster in GitHub Actions when using the following `actions/checkout@v4` configuration for some reason:
```yaml
- uses: actions/checkout@v4
  with:
    submodules: true
```

Once the `void-packages` repository is checked out and `void-packages/xbps-src` as well as your build script are available, run the build script within a container image (we'll use `x86_64` for now):
```yaml
- name: Create XBPS packages
  run: |
    docker run --rm \
      -v $(pwd):/workspace \
      ghcr.io/xdeb-org/voidlinux-repository:x86_64 \
      /workspace/scripts/build.sh

    sudo chown -R $(id -u):$(id -g) void-packages/hostdir/binpkgs
```

After successful container execution, the XBPS packages are going to be available at `$(pwd)/void-packages/hostdir/binpkgs`, but they will be owned by the `root` user, since the container was running as `root`. `sudo chown` is used to fix that.

For a more advanced example, have a look at the `GitHub Pages` job from the `main` branch of this project which utilizes a `matrix` to build XBPS packages for multiple architectures: https://github.com/xdeb-org/voidlinux-repository/blob/main/.github/workflows/pages.yml

## How to sign XBPS packages

To sign XBPS packages using these container images, create a script which does the job and execute that via `docker run`. The procedure is roughly the same as [How to use in CI environments](#how-to-use-in-ci-environments). There are a few differences, though:
  1. You don't need `void-packages` anymore
  2. You have to have a private key in PEM format available as a file within the container

Follow https://docs.voidlinux.org/xbps/repositories/signing.html to learn more.

## How to use manually

**Note**: Discouraged! Don't do this! This section is just here for demonstration. Performing these steps will mess up file permissions on your `void-packages` directory besides causing other possible side effects. You have been warned!

Using the image is fairly simple:
  1. Clone the `void-packages` repository:
  ```
  $ git clone https://github.com/void-linux/void-packages.git
  ```
  2. Pull an image for your architecture, say `x86_64`:
  ```
  $ docker pull ghcr.io/xdeb-org/voidlinux-repository:x86_64
  ```
  3. Run the container and mount `void-packages` as a volume:
  ```
  $ docker run --rm \
    -v $(pwd)/void-packages:/void-packages \
    -w /void-packages \
    -it ghcr.io/xdeb-org/voidlinux-repository:x86_64 \
    bash
  ```
  4. Verify that you've landed within the `/void-packages` directory:
  ```
  bash-5.1# pwd
  /void-packages
  ```
  5. Link the container's root FS to `/void-packages/masterdir`, so `xbps-src` knows it doesn't have to create a chroot environment:
  ```
  bash-5.1# ln -sf / masterdir
  ```
  6. Use `xbps-src` and `xtools` as you would normally do:
  ```
  bash-5.1# ./xbps-src xnew <pkgname>
  bash-5.1# xlint <pkgname>
  bash-5.1# ./xbps-src pkg -Q <pkgname>
  ```
  7. When you're finished, exit the container:
  ```
  bash-5.1# exit
  ```

It took me a while to get behind step 5, because I didn't realize that a container environment can be seen as a chroot environment all the same. Notice that after step 5 you don't have to execute `./xbps-src binary-bootstrap`, because the packages are already available in the container environment. Executing that command won't do anything.
