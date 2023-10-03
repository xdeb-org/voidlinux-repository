# Custom Void Linux repository

This project represents my own custom Void Linux repository. It contains various XBPS packages for various architectures which didn't make the merge into the official [void-linux/void-packages](https://github.com/void-linux/void-packages) repository for one reason or another.

To get an overview of the available packages, visit https://thetredev.github.io/voidlinux-repository.

The entire repository is managed via GitHub Actions (see [`.github/workflows`](.github/workflows)) and custom container images (see the [Branches](#branches) section below). The only thing hidden from the public is my private RSA key which is used to sign the XBPS package repository.

## How to install

In order to install packages from this repository, create a new `.conf` file in the `/etc/xbps.d` directory containing the repository URL:
```
# /etc/xbps.d/99-thetredev.conf

repository=https://thetredev.github.io/voidlinux-repository
```

Then, synchronize the XBPS repositories:
```
$ sudo xbps-install -S
```

XBPS will ask you to import my RSA key. **Double check** the correctness of the key:
```
Signed-by: Timo Reichl <thetredev@gmail.com>
Fingerprint: a9:e3:1f:07:e6:ff:c8:74:2a:f5:b6:22:5c:6d:d4:16
```

After importing the key, you can execute `xbps-install <package>` to install any of the packages available for your host architecture at https://thetredev.github.io/voidlinux-repository.

## Branches

| Branch | Purpose
| --- | --- |
| `main` | This branch. Used to build and release all XBPS packages listed within the [`packages`](./packages) directory. |
| `docker` | Used to build and release custom container images to be able to easily build XBPS packages. |
| `pages` | Locked placeholder branch to stop GitHub from executing the automatic GitHub Pages CI pipeline. The `main` branch contains a custom Pages CI pipeline. |

## Conventions

### Package version updates
On package version updates, the revision stays the same. Example:
```diff
-version=1.0.0
+version=1.0.1
revision=1
```

### Build environment updates
On build environment changes, e.g. updates to submodules, updates to build scripts and/or GitHub workflows, the version stays the same, while the revision is incremented. Example:
```diff
version=1.0.0
-revision=1
+revision=2
```

### Revision reset
If the revision was higher than 1, and a package version was updated, the revision is reset to 1, regardless of build environment updates within the same commit. Example:
```diff
-version=1.0.0
+version=1.0.1
-revision=2
+revision=1
```
