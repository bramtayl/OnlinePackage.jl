const settings_file = joinpath((@__FILE__) |> dirname |> dirname, "remotes.json")

export set_up
"""
    set_up(username, github_token, appveyor_token; ssh_keygen_file = "ssh-keygen")

Set up `OnlinePackage`.

Get a `github_token` [here](https://github.com/settings/tokens/new). Make
sure to check the `"public_repo"` and `"delete_repo"` scopes.

Get a `appveyor_token` [here](https://ci.appveyor.com/api-token).

The default `ssh-keygen_file` assumes ssh-keygen is in your path. For
Windows users with git installed, try
`ssh_keygen_file = "C:/Program Files/Git/usr/bin/ssh-keygen"`.
"""
set_up(username, github_token, appveyor_token;
    travis_token = get_travis_token(github_token),
    ssh_keygen_file = "ssh-keygen",
    file = settings_file
) = open(file, "w") do io
    JSON.print(io, Dict(
        "username" => username,
        "github_token" => github_token,
        "travis_token" => travis_token,
        "appveyor_token" => appveyor_token,
        "ssh_keygen_file" => ssh_keygen_file))
end

function settings(name; file = settings_file)
    if !ispath(file)
        error("Cannot find settings. Please `set_up`")
    end
    dict = JSON.parsefile(file)
    if !haskey(dict, name)
        error("Missing setting $name")
    end
    dict[name]
end
