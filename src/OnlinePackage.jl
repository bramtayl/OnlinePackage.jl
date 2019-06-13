module OnlinePackage

using Base: Generator
using Base64: base64encode
import HTTP
import JSON
import JSON: json
import Pkg: TOML

"where OnlinePackage will look for your user information"
const USER_FILE = joinpath(dirname(dirname(@__FILE__)), "online_package.toml")
export USER_FILE

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

first_as_symbol(pair) = Symbol(pair.first) => pair.second

"""
    get_user(user_file = USER_FILE)

create a user profile from a file. by default, looks in `USER_FILE`

the file must contain a `username`, `github_token`, `travis_token`, and `ssh_keygen_file`. see the sample.toml file for an example.

use your github username.

get a `github_token` [here](https://github.com/settings/tokens/new). make sure to check the `public_repo` scope, and optionally, the `delete_repo` scope.

get your `travis_token` [here](https://travis-ci.com/account/preferences).

if ssh-keygen is in your path, just set `ssh_keygen_file` to "ssh-keygen". if not, it often comes prepacked with git; check `PATH_TO_GIT/usr/bin/ssh-keygen"`.
"""
function get_user(user_file = USER_FILE)
    user_dict = open(TOML.parse, user_file)
    user_dict["github_token"] = replace(user_dict["github_token"], '~' => "a")
    User(; Generator(first_as_symbol, user_dict)...)
end
export get_user

function talk_to(request, remote::Remote, url, args...)
    body = json(Dict(args...))
    if body == "{}"
        body = ""
    end
    response = request(
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

check_name(repo, repo_name) = repo["name"] == repo_name

exists(user::User, repo_name) = any(
    let repo_name = repo_name
        check_name_capture(repo) = check_name(repo, repo_name)
    end,
    json_string(talk_to(HTTP.get, github(user), "/user/repos?per_page=100"))
)

github(user::User) = Remote("https://api.github.com", user.github_token)

function make_key(ssh_keygen_file, key_name)
    run(`$ssh_keygen_file -f $key_name -N "" -q`)
    read(string(key_name, ".pub"), String),
        read(key_name, String) |> chomp |> base64encode
end
make_key_at(temp_file, ssh_keygen_file, key_name) = cd(
    let ssh_keygen_file = ssh_keygen_file, key_name = key_name
        make_key_capture() = make_key(ssh_keygen_file, key_name)
    end,
    temp_file
)

function delete_github_key(github_remote, key, key_name)
    if key["title"] == key_name
        talk_to(HTTP.delete, github_remote, "$github_keys/$(key["id"])")
    end
    nothing
end

function delete_travis_key(travis_remote, key, key_name)
    if key["name"] == key_name
        talk_to(HTTP.delete, travis_remote, "/repo/$repo_code/env_var/$(key["id"])")
    end
    nothing
end


"""
    put_online(user::User, repo_name)

put a repository online: create a github and travis repository (if they don'travis_remote already exist) and connect them with a key.

```jldoctest
julia> using OnlinePackage

julia> user = get_user(joinpath(dirname(pwd()), "sample.toml"));

julia> put_online(user, "Test.jl")

julia> delete(user, "Test.jl")
```
"""
function put_online(user::User, repo_name)
    username = user.username
    github_remote = github(user)
    travis_remote = Remote("https://api.travis-ci.com", user.travis_token)

    if !exists(user, repo_name)
        talk_to(HTTP.post, github_remote, "/user/repos", "name" => repo_name)
        sleep(1)
    end

    repo_code = json_string(talk_to(HTTP.get, travis_remote, "/repo/$username%2F$repo_name"))["id"]

    ssh_keygen_file = user.ssh_keygen_file
    key_name = "DOCUMENTER_KEY"

    public_key, private_key = mktempdir(
        let ssh_keygen_file = ssh_keygen_file, key_name = key_name
            make_key_at_capture(temp_file) =
                make_key_at(temp_file, ssh_keygen_file, key_name)
        end
    )

    github_keys = "/repos/$username/$repo_name/keys"
    foreach(
        let github_remote = github_remote, key_name = key_name
            delete_github_key_capture(key) =
                delete_github_key(github_remote, key, key_name)
        end,
        json_string(talk_to(HTTP.get, github_remote, github_keys))
    )
    talk_to(HTTP.post, github_remote, github_keys,
        "title" => key_name,
        "key" => public_key,
        "read_only" => false
    )

    travis_keys = "/repo/$repo_code/env_vars"
    foreach(
        let travis_remote = travis_remote, key_name = key_name
            delete_travis_key_capture(key) =
                delete_travis_key(travis_remote, key, key_name)
        end,
        json_string(talk_to(HTTP.get, travis_remote, travis_keys))["env_vars"]
    )
    talk_to(HTTP.post, travis_remote, travis_keys,
        "env_var.name" => "DOCUMENTER_KEY",
        "env_var.value" => private_key,
        "env_var.public" => false
    )
    nothing
end
export put_online

"""
    delete(user::User, repo_name)

delete a repository.
"""
function delete(user::User, repo_name)
    if exists(user, repo_name)
        talk_to(HTTP.delete, github(user), "/repos/$(user.username)/$repo_name")
    end
    nothing
end
export delete

end
