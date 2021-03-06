# Freedesktop SDK

The [Freedesktop SDK](https://freedesktop-sdk.io/ ) project provides Platform
and SDK runtimes for
[Flatpak](https://flatpak.org) apps and runtimes based on Freedesktop modules.
It was originally started as a [Flatpak subproject](https://github.com/flatpak/freedesktop-sdk-images)
to create a basic-neutral runtime. It is now a separate project, similar to
what happened with the GNOME and KDE runtimes.

As explained in [Alex's blog post](https://blogs.gnome.org/alexl/2018/05/16/introducing-1-8-freedesktop-runtime/)
there has long been a desire to upgrade and modernize the SDK, which is where
this specific project comes into the story.

This is a diagram of how the Freedeskop SDK runtimes interact with the rest of
the Flatpak ecosystem:

```mermaid
graph TD;
app(Flatpak Application) --> GNOME_SDK(GNOME SDK.);
GNOME_SDK(GNOME SDK.) --> freedesktop-sdk(freedesktop-sdk);
app(Flatpak Application) --> freedesktop-sdk(freedesktop-sdk);
app(Flatpak Application) --> KDE_SDK(KDE SDK);
KDE_SDK(KDE SDK) --> freedesktop-sdk(freedesktop-sdk);
freedesktop-sdk(freedesktop-sdk) --> linux(Linux-based OS)
freedesktop-sdk(freedesktop-sdk) --> container(Docker container)
style app fill:#f9f,stroke:#333,stroke-width:2px
style KDE_SDK fill:#591,stroke:#333,stroke-width:2px
style GNOME_SDK fill:#591,stroke:#333,stroke-width:2px
style freedesktop-sdk fill:#ee4,stroke:#333,stroke-width:2px
```

Our goals, some of which are already achieved:

*   Improve maintainability, using a single metadata format instead of several
    different ones. We use [BuildStream](https://gitlab.com/BuildStream/buildstream)
    for this.
*   Support multiple architectures out of the box. (ppc64le, armv7, aarch64, i386, and x86_64)
*   Long term maintenance of the SDK, with improved automation to do so,
    including tests for ABI stability.
*   Define formal release cycles.
*   Host on official freedesktop.org infrastructure.
*   Add minimal bootable system and generic sysroot.
*   Maintain a neutral baseline which can be consumed by Flatpak, GNOME, KDE
    and any other interested project.

The Freedesktop SDK project is not an endorsement of a particular platform or
selection of technologies by the Freedesktop organization.
The SDK aims to support a common interoperable platform for projects such as
GNOME, KDE and Flatpak by providing integration and validation of a shared
set of dependencies.

## Usage

Currently the Freedesktop SDK is meant to be used as the base for all Flatpak
applications.

We recommend you install releases from [Flathub](https://flathub.org).

The current set of commands to run your application with 19.08 are:

1.  Install the new runtimes:

    ```
    $ flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    $ flatpak install flathub org.freedesktop.Sdk//19.08
    $ flatpak install flathub org.freedesktop.Platform//19.08
    ```

2.  Set your app manifest:

    ```
    "runtime-version": "19.08"
    ```

3. Build and run your flatpak app as usual:

    ```
    $ flatpak-builder build_folder org.app.json
    $ flatpak-builder --run build_folder org.app.json
    ```

## Available Runtimes

Currently we provide the following runtimes:
* org.freedesktop.Platform
* org.freedesktop.Sdk

Additionally we provide the following extensions to our platform:
* org.freedesktop.Platform.Locale
* org.freedesktop.Platform.VAAPI.Intel{,.i386} (Intel only)
* org.freedesktop.Platform.ffmpeg-full
* org.freedesktop.Platform.Compat.{architecture}
* org.freedesktop.Platform.Compat.{architecture}.debug
* org.freedesktop.Platform.GL{,32}.default
* org.freedesktop.Platform.GL{,32}.mesa-git

And the following extensions to the SDK:
* org.freedesktop.Sdk.Locale
* org.freedesktop.Sdk.Docs
* org.freedesktop.Sdk.Debug
* org.freedesktop.Sdk.Extension.rust-stable
* org.freedesktop.Sdk.Extension.toolchain-{architecture}

We also provide following flatpak applications useful for testing GPU:
* org.freedesktop.ClInfo
* org.freedesktop.GlxInfo
* org.freedesktop.GlxInfo.Debug
* org.freedesktop.VaInfo
* org.freedesktop.VaInfo.Debug
* org.freedesktop.VulkanInfo

## HTML5 Codecs

For the 18.08 release cycle we provided a runtime extension containing the
codecs required to play H.264 encoded video, however things are changing for the
19.08 release. The `ffmpeg-html5` extension is now deprecated, and cannot be
relied upon, so it's not longer safe to assume a user has H.264 support.

We intend to provide an `openh264` extension, which will provide a royalty free
H.264 codec. However, this extension will only be available for flatpak version
1.4.2 or later. This is (at present) packaged in very few distros.

The main takeaway is this: **if you need to use H.264 codecs, include the
ffmpeg-full extension with your app**.

For an example of this, see `tests/test.codecs.ffmpeg-full.json`, which is a
flatpak manifest for an app using the full codecs.

## libudev
Since 19.08 release, freedesktop-sdk flatpak runtime ships libudev library.
This is dedicated for apps which need to link against it during build and
later at runtime.

In flatpak it's use-case is limited to a simple PCI device enumarator without
access to udevd database as upstream doesn't guarantee API stability there
(See https://lists.freedesktop.org/archives/systemd-devel/2014-October/024498.html)
and mismatch between flatpak's and host versions may cause broken functionality.

## Structure

Current directory structure is the usual of a buildstream project with the
exception of the `bootstrap/` folder which contains a buildstream subproject
with a set of instructions to bootstrap a minimal sysroot, used to build all
the Flatpak runtimes defined in the `elements/` folder.

The `plugins/` directory contains our custom Buildstream
[plugins](https://buildstream.gitlab.io/buildstream/pluginindex.html#plugins)

## Extending the runtime
Freedesktop SDK aims to be an agnostic, minimal runtime, so we ship a small subset of dependencies.

However, if you would like to use Freedesktop SDK for your own use case, we do support users "extending"
the runtime. There are multiple ways to do this, we provide many ways to consume the runtime, such as ostree checkouts, Docker(OCI) container images and tarballs. Along side this as we use BuildStream to build the runtime, we also support the concept of "junctioning" the project, which is documented in this [guide](https://gitlab.com/freedesktop-sdk/freedesktop-sdk/wikis/Using%20freedesktop-sdk#buildstream-projects).


## Contributing

For a guide to contributing, please see our [CONTRIBUTING](https://gitlab.com/freedesktop-sdk/freedesktop-sdk/blob/19.08/CONTRIBUTING.md) file.

## Acknowledgements

This project wouldn't be possible without the work of a few individuals and
groups, and we would like to take a moment to thank them.

*   Alex Larsson, who not only gave us [Flatpak](https://flatpak.org) but also
    the original
    [Freedesktop Sdk](https://github.com/flatpak/freedesktop-sdk-images)
    (versions 1.2 to 1.6);
*   the wider Flatpak community, of which we are only a small part, and who
    constantly help us;
*   the [BuildStream](https://buildstream.build/) community, who offered this
    amazing tool to the world which makes building and maintaining our project
    so easy and fun;
*   Dodji Seketeli who wrote [libabigail](https://sourceware.org/libabigail/),
    which allows us to ensure we do not break apps, and tirelessly works with
    us on fixing any bug we encounter;
*   [Codethink](https://www.codethink.co.uk/), for assigning some of their
    engineers' time to this project;
