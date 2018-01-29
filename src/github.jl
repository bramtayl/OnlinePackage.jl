struct GitHub <: Remote
    repo_name::String
    username::String
    token::String
end

GitHub(repo_name) =
    GitHub(repo_name, settings("username"), settings("github_token"))

base_url(g::GitHub) = "https://api.github.com"
headers(g::GitHub) = Dict("Authorization" => "token $(g.token)")

function repos(g::GitHub)
    info("Getting github repos")
    talk_to(HTTP.get, g, "/user/repos?per_page=100") |> json_parse
end

function create(g::GitHub)
    info("Creating github")
    talk_to(HTTP.post, g, "/user/repos", Dict(
        "name" => g.repo_name) )
end

function key(g::GitHub, name, value; read_only = false)
    info("Creating github key")
    talk_to(HTTP.post, g, "/repos/$(g.username)/$(g.repo_name)/keys", Dict(
        "title" => name,
        "key" => value,
        "read_only" => read_only) )
end

# note only checks the first 100 repos, sorry
function exists(g::GitHub)
    any(repos(g)) do repo
        repo["name"] == g.repo_name
    end
end

function delete(g::GitHub)
    info("Deleting github")
    talk_to(HTTP.delete, g, "/repos/$(g.username)/$(g.repo_name)")
end
