module OnlinePackage

using Base: Generator
using Base64: base64encode, base64decode
using libsodium_jll
import HTTP
import JSON
import JSON: json
import Pkg: TOML

include("mini_sodium.jl")

"""
where OnlinePackage will look for your user information
"""
const USER_FILE = joinpath(dirname(@__DIR__), "online_package.toml")
export USER_FILE

const SAMPLE_FILE = joinpath(dirname(@__DIR__), "sample.toml")

struct User
    base_url::String
    username::String
    token::String
    ssh_keygen_file::String
end

User(; username, token, ssh_keygen_file) =
    User("https://api.github.com", username, token, ssh_keygen_file)

"""
    get_user(user_file = USER_FILE)

Create a user profile from a TOML file. By default, looks in `USER_FILE`.

The file must contain a `username`, `token`, and `ssh_keygen_file`. See
the sample.toml file in this repository for an example. It should look something like the
following:

```
username = "YOUR_GITHUB_USERNAME"
token = "YOUR_GITHUB_TOKEN"
ssh_keygen_file = "PATH_TO_SSH_KEYGEN"
```

Use your github `username`.

Get a `token` [here](https://github.com/settings/tokens/new). Make sure
to check the `public_repo` scope, and optionally, the `delete_repo` scope.

If ssh-keygen is in your path, just set `ssh_keygen_file` to "ssh-keygen". If
not, it often comes prepacked with git; check `PATH_TO_GIT/usr/bin/ssh-keygen"`.
"""
function get_user(user_file = USER_FILE)
    user_dict = open(TOML.parse, user_file)
    user_dict["token"] = replace(user_dict["token"], '~' => 'c')
    User(; (Symbol(pair.first) => pair.second for pair in user_dict)...)
end
export get_user

function talk_to(request, user::User, sub_url; args...)
    body = json(Dict(args))
    if body == "{}"
        body = ""
    end
    response = request(
        string(user.base_url, sub_url),
        headers = Dict(
            "Content-Type" => "application/json",
            "Authorization" => "token $(user.token)",
            "User-Agent" => "OnlinePackage",
        ),
        body = body,
    )
    response.body
end

json_string(x) = x |> String |> JSON.parse

exists(user::User, repo_name) = any(
    repo["name"] == repo_name
    for repo in json_string(talk_to(HTTP.get, user, "/user/repos?per_page=100"))
)

function add_key(user, repo_name, key_name)
    username = user.username
    ssh_keygen_file = user.ssh_keygen_file
    public_key, private_key = mktempdir() do temp_file
        cd(temp_file) do
            run(`$ssh_keygen_file -f $key_name -N "" -q`)
            read(string(key_name, ".pub"), String), base64encode(read(key_name, String))
        end
    end

    repos_url = "/repos/$username/$repo_name"

    keys_url = "$repos_url/keys"
    for key in json_string(talk_to(HTTP.get, user, keys_url))
        if key["title"] == key_name
            talk_to(HTTP.delete, user, "$keys_url/$(key["id"])")
        end
    end
    talk_to(
        HTTP.post,
        user,
        keys_url,
        title = key_name,
        key = public_key,
        read_only = false,
    )

    secrets_url = "$repos_url/actions/secrets"

    for secret in json_string(talk_to(HTTP.get, user, secrets_url))["secrets"]
        if secret["name"] == key_name
            talk_to(HTTP.delete, user, "$secrets_url/$key_name")
        end
    end

    init_error_code = sodium_init()
    if init_error_code < 0
        error("Error using libsodium.sodium_init: code $init_error_code")
    end

    sodium_key_id = json_string(talk_to(HTTP.get, user, "$secrets_url/public-key"))

    sodium_key = base64decode(sodium_key_id["key"])
    raw_encoded = Vector{Cuchar}(undef, crypto_box_sealbytes() + length(private_key))
    error_code = crypto_box_seal(raw_encoded, private_key, length(private_key), sodium_key)
    if error_code != 0
        error("Error using libsodium.crypto_box_seal: code $error_code")
    end
    talk_to(
        HTTP.put,
        user,
        "$secrets_url/$key_name",
        encrypted_value = base64encode(raw_encoded),
        key_id = sodium_key_id["key_id"],
    )
    nothing
end

"""
    put_online(user::User, repo_name; key_names = ("COMPATHELPER_PRIV",))

Put a repository online: put it on github, and create SSH keys with names listed in
`key_names` for use in various github actions. If the repository already exists, it will
create a new set of keys.

```jldoctest
julia> using OnlinePackage

julia> repo_name = "Test$VERSION.jl";

julia> user = get_user(OnlinePackage.SAMPLE_FILE);

julia> put_online(user, repo_name)

julia> put_online(user, repo_name)

julia> delete(user, repo_name)
```
"""
function put_online(user::User, repo_name; key_names = ("COMPATHELPER_PRIV",))
    username = user.username

    if !exists(user, repo_name)
        talk_to(HTTP.post, user, "/user/repos", name = repo_name)
        sleep(1)
    end

    ssh_keygen_file = user.ssh_keygen_file
    for key_name in key_names
        add_key(user, repo_name, key_name)
    end
    nothing
end
export put_online

"""
    delete(user::User, repo_name)

Delete a repository.
"""
function delete(user::User, repo_name)
    if exists(user, repo_name)
        talk_to(HTTP.delete, user, "/repos/$(user.username)/$repo_name")
    end
    nothing
end
export delete

end
