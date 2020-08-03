# OnlinePackage

## Interface

```@index
Modules = [OnlinePackage]
```

```@autodocs
Modules = [OnlinePackage]
```

## Walk-through

Currently, OnlinePackage is only set up to handle GitHub accounts, but other platforms might
be supported in the future.

The first step to use OnlinePackage is to fill out your user information.
[`USER_FILE`](@ref) will be the location that OnlinePackage will look, so create that file.

The contents of the file should look like this:

```
username = "YOUR_GITHUB_USERNAME"
token = "YOUR_GITHUB_TOKEN"
ssh_keygen_file = "PATH_TO_SSH_KEYGEN"
```

See the documentation for [`get_user`](@ref) for information about how to create this
information.

Then run

```
user = get_user()
```

to load the file. You can then put up a new package:

```
put_online(user, "YOUR_NEW_PACKAGE.jl")
```

OnlinePackage will automatically create SSH keys to enable various GitHub actions. The only
key created by default is for CompatHelper: `COMPATHELPER_PRIV`. You can add as many
additional keys as you like. For example, if you would also like a documenter key, you can
run

```
put_online(user, "YOUR_NEW_PACKAGE.jl", key_names = ("COMPATHELPER_PRIV", "DOCUMENTER_KEY"))
```

Note that Documenter can use a generic `GITHUB_TOKEN` provided you enable github pages, so
this is not strictly necessary.

You can also use OnlinePackage to add keys to previously existing packages. The syntax is
the same as above: OnlinePackage will automatically detect an existing package.
