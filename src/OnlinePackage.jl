module OnlinePackage

using Base: Generator
using Base64: base64encode, base64decode
using libsodium_jll
import HTTP
import JSON
import JSON: json
import Pkg: TOML

include("mini_sodium.jl")

"where OnlinePackage will look for your user information"
const USER_FILE = joinpath(dirname(@__DIR__), "online_package.toml")
export USER_FILE

PAGE_LIMIT = 100 # the user should be able to change this if they have more than 100 repos

const SAMPLE_FILE = joinpath(dirname(@__DIR__), "sample.toml")

struct Remote
    base_url::String
    token::String
end

struct User
    username::String
    github_token::String
    ssh_keygen_file::String
end

User(; username, github_token, ssh_keygen_file) =
    User(username, github_token, ssh_keygen_file)

"""
    get_user(user_file = USER_FILE)

Create a user profile from a TOML file. By default, looks in `USER_FILE`

The file must contain a `username`, `github_token`, and `ssh_keygen_file`. See
the sample.toml file in this repository for an example.

Use your github username.

Get a `github_token` [here](https://github.com/settings/tokens/new). Make sure
to check the `public_repo` scope, and optionally, the `delete_repo` scope.

If ssh-keygen is in your path, just set `ssh_keygen_file` to "ssh-keygen". If
not, it often comes prepacked with git; check `PATH_TO_GIT/usr/bin/ssh-keygen"`.
"""
function get_user(user_file = USER_FILE)
    user_dict = open(TOML.parse, user_file)
    user_dict["github_token"] = replace(user_dict["github_token"], '~' => 'c')
    User(; (Symbol(pair.first) => pair.second for pair in user_dict)...)
end
export get_user

function talk_to(request, remote::Remote, url; args...)
    body = json(Dict(args))
    if body == "{}"
        body = ""
    end
    response = request(
        string(remote.base_url, url),
        headers = Dict(
            "Content-Type" => "application/json",
            "Authorization" => "token $(remote.token)",
            "User-Agent" => "OnlinePackage"
        ),
        body = body
    )
    response.body
end

json_string(x) = x |> String |> JSON.parse

exists(user::User, repo_name) = any(
    repo["name"] == repo_name for repo in json_string(
        talk_to(HTTP.get, github(user), "/user/repos?per_page=$PAGE_LIMIT")
    )
)

github(user::User) = Remote("https://api.github.com", user.github_token)

"""
    put_online(user::User, repo_name)

Put a repository online: put it on github, and create an SSH key to allow github
actions to push to github. If the repository already exists, it will create a
new set of keys.

```jldoctest
julia> using OnlinePackage

julia> repo_name = "Test$VERSION.jl";

julia> user = get_user(OnlinePackage.SAMPLE_FILE);

julia> put_online(user, repo_name)

julia> put_online(user, repo_name)

julia> delete(user, repo_name)
```
"""
function put_online(user::User, repo_name)
    username = user.username
    github_remote = github(user)

    if !exists(user, repo_name)
        talk_to(HTTP.post, github_remote, "/user/repos", name = repo_name)
        sleep(1)
    end

    ssh_keygen_file = user.ssh_keygen_file
    key_name = "DOCUMENTER_KEY"

    public_key, private_key = mktempdir() do temp_file
        cd(temp_file) do
            run(`$ssh_keygen_file -f $key_name -N "" -q`)
            read(string(key_name, ".pub"), String),
                base64encode(read(key_name, String))
        end
    end

    github_keys = "/repos/$username/$repo_name/keys"
    for key in json_string(talk_to(HTTP.get, github_remote, github_keys))
        if key["title"] == key_name
            talk_to(HTTP.delete, github_remote, "$github_keys/$(key["id"])")
        end
    end

    talk_to(HTTP.post, github_remote, github_keys,
        title = key_name,
        key = public_key,
        read_only = false
    )

    github_secrets = "/repos/$username/$repo_name/actions/secrets"

    for secret in json_string(talk_to(HTTP.get, github_remote, github_secrets))["secrets"]
        if secret["name"] == key_name
            talk_to(HTTP.delete, github_remote, "$github_secrets/$key_name")
        end
    end

    init_error_code = sodium_init()
    if init_error_code < 0
        error("Error using libsodium.sodium_init")
    end

    sodium_key_id = json_string(talk_to(HTTP.get, github_remote,
        "$github_secrets/public-key"
    ))

    sodium_key = base64decode(sodium_key_id["key"])
    raw_encoded = Vector{Cuchar}(undef, crypto_box_sealbytes() + length(private_key))
    error_code = crypto_box_seal(
        raw_encoded,
        private_key,
        length(private_key),
        sodium_key
    )
    if error_code != 0
        error("Error using libsodium.crypto_box_seal")
    end
    talk_to(
        HTTP.put, github_remote, "$github_secrets/$key_name",
        encrypted_value = base64encode(raw_encoded),
        key_id = sodium_key_id["key_id"]
    )
    nothing
end
export put_online

"""
    delete(user::User, repo_name)

Delete a repository.
"""
function delete(user::User, repo_name)
    if exists(user, repo_name)
        talk_to(HTTP.delete, github(user), "/repos/$(user.username)/$repo_name")
    end
    nothing
end
export delete

end
