module OnlinePackage

using Base: Generator
using Base64: base64encode, base64decode
using libsodium_jll: libsodium
import HTTP
import JSON
import JSON: json
import Pkg: TOML

"where OnlinePackage will look for your user information"
const USER_FILE = joinpath(dirname(@__DIR__), "online_package.toml")
export USER_FILE

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

The file must contain a `username`, `github_token`, and `ssh_keygen_file`. see the sample.toml file for an example.

Use your github username.

Get a `github_token` [here](https://github.com/settings/tokens/new). Make sure
to check the `public_repo` scope, and optionally, the `delete_repo` scope.

If ssh-keygen is in your path, just set `ssh_keygen_file` to "ssh-keygen". If
not, it often comes prepacked with git; check `PATH_TO_GIT/usr/bin/ssh-keygen"`.
"""
function get_user(user_file = USER_FILE)
    user_dict = open(TOML.parse, user_file)
    user_dict["github_token"] = replace(user_dict["github_token"], '~' => "a")
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
        talk_to(HTTP.get, github(user), "/user/repos?per_page=100")
    )
)

github(user::User) = Remote("https://api.github.com", user.github_token)

"""
    put_online(user::User, repo_name)

Put a repository online: put it on github, and create an SSH key to allow github
actions to push to github.

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
                read(key_name, String) |> chomp
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

    for secret in json_string(talk_to(HTTP.get, github_remote, "/repos/$username/$repo_name/actions/secrets"))["secrets"]
        if secret["title"] == key_name
            talk_to(HTTP.delete, github_remote, "/repos/$username/$repo_name/actions/secrets/$key_name")
        end
    end

    sodium_key_id = json_string(talk_to(HTTP.get, github_remote,
        "/repos/$username/$repo_name/actions/secrets/public-key"
    ))

    sodium_key = base64decode(sodium_key_id["key"])
    raw_encoded = Vector{UInt8}(undef,
        length(private_key) +
        ccall((:crypto_box_sealbytes, libsodium), Cint, ())
    )
    error_code = ccall(
        (:crypto_box_seal, libsodium),
        Int32,
        (Ptr{UInt8}, Cstring, Cint, Ptr{UInt8}),
        raw_encoded, private_key, length(private_key), sodium_key
    )
    if error_code != 0
        error("Error using libsodium.crypto_box_seal")
    end
    talk_to(
        HTTP.put, github_remote, "/repos/$username/$repo_name/actions/secrets/$key_name",
        encrypted_value = base64encode(unsafe_string(pointer(raw_encoded), length(raw_encoded))),
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
