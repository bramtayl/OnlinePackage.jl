module OnlinePackage

import HTTP
import Pkg: TOML
import JSON
import JSON: json
using Base64: base64encode

export USER_FILE

"Where OnlinePackage will look for your user information"
const USER_FILE = joinpath(dirname(dirname(@__FILE__)), "online_package.toml")

struct Remote
    base_url::String
    token::String
end

struct User
    username::String
    github_token::String
    travis_token::String
    ssh_keygen_file::String
end

User(; username, github_token, travis_token, ssh_keygen_file = "ssh-keygen") =
    User(username, github_token, travis_token, ssh_keygen_file)

export user
"""
    user(user_file = USER_FILE)

create a user profile from a file. by default, looks in `USER_FILE`

the file must contain a `username`, `github_token`, `travis_token`, and
`ssh_keygen_file`. see the sample.toml file for an example.

use your github username.

get a `github_token` [here](https://github.com/settings/tokens/new). make
sure to check the `"public_repo"` scope.

get your `travis_token` [here](https://travis-ci.com/account/preferences).

if ssh-keygen is in your path, just set `ssh_keygen_file` to "ssh-keygen". if not,
it often comes prepacked with git; check `PATH_TO_GIT/usr/bin/ssh-keygen"`.
"""
user(user_file = USER_FILE) =
    User(; (Symbol(pair.first) => pair.second for pair in open(TOML.parse, user_file))...)

function talk_to(f, remote::Remote, url, args...)
    body = json(Dict(args...))
    if body == "{}"
        body = ""
    end
    response = f(
        string(remote.base_url, url),
        headers = Dict(
            "Travis-API-Version" => "3",
            "Content-Type" => "application/json",
            "Authorization" => "token $(remote.token)",
            "User-Agent" => "OnlinePackage/0.0.1"
        ),
        body = body
    )
    if response.status >= 300
        error("$(response.status) $(response.statustext): $(String(response.body))")
    end
    response.body
end

json_string(x) = x |> String |> JSON.parse

exists(u::User, repo_name) = any(
    repo -> repo["name"] == repo_name,
    json_string(talk_to(HTTP.get, github(u), "/user/repos?per_page=100"))
)

github(u::User) = Remote("https://api.github.com", u.github_token)

export put_online
"""
put_online(u::User, repo_name)

put a repository online: create a github and travis repository (if they don't
already exist) and connect them with a key.

```jldoctest
julia> using OnlinePackage

julia> u = user(joinpath(dirname(pwd()), "sample.toml"));

julia> put_online(u, "Test.jl")

julia> delete(u, "Test.jl")
```
"""
function put_online(u::User, repo_name)
    username = u.username
    g = github(u)
    t = Remote("https://api.travis-ci.com", u.travis_token)

    if !exists(u, repo_name)
        talk_to(HTTP.post, g, "/user/repos", "name" => repo_name)
        sleep(1)
    end

    repo_code = json_string(talk_to(HTTP.get, t, "/repo/$username%2F$repo_name"))["id"]

    ssh_keygen_file = u.ssh_keygen_file
    key_name = "DOCUMENTER_KEY"

    public_key, private_key = mktempdir() do temp
        cd(temp) do
            try
                read(`$ssh_keygen_file -f $key_name -N ""`, String)
            catch x
                if isa(x, Base.UVError)
                    error("Cannot find $ssh_keygen_file")
                else
                    rethrow()
                end
            end
            read(string(key_name, ".pub"), String),
                read(key_name, String) |> chomp |> base64encode
        end
    end
    github_keys = "/repos/$username/$repo_name/keys"
    foreach(
        key ->
            if key["title"] == key_name
                talk_to(HTTP.delete, g, "$github_keys/$(key["id"])")
            end,
        json_string(talk_to(HTTP.get, g, github_keys))
    )
    talk_to(HTTP.post, g, github_keys,
        "title" => key_name,
        "key" => public_key,
        "read_only" => false
    )

    travis_keys = "/repo/$repo_code/env_vars"
    foreach(
        key ->
            if key["name"] == key_name
                talk_to(HTTP.delete, t, "/repo/$repo_code/env_var/$(key["id"])")
            end,
        json_string(talk_to(HTTP.get, t, travis_keys))["env_vars"]
    )
    talk_to(HTTP.post, t, travis_keys,
        "env_var.name" => "DOCUMENTER_KEY",
        "env_var.value" => private_key,
        "env_var.public" => false
    )
    nothing
end

export delete
"""
    delete(u::User, repo_name)

delete a repository.
"""
function delete(u::User, repo_name)
    if exists(u, repo_name)
        talk_to(HTTP.delete, github(u), "/repos/$(u.username)/$repo_name")
    end
    nothing
end

end
