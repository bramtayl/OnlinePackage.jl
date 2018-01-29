mutable struct AppVeyor <: Remote
    repo_name::String
    username::String
    token::String
    repo_code::String
end

AppVeyor(repo_name) =
    AppVeyor(repo_name, settings("username"), settings("appveyor_token"), "")

base_url(a::AppVeyor) = "https://ci.appveyor.com/"
headers(a::AppVeyor) = Dict("Authorization" => "Bearer $(a.token)")

function repos(a::AppVeyor)
    info("Getting appveyor repos")
    talk_to(HTTP.get, a, "/api/projects") |> json_parse
end

function create(a::AppVeyor)
    info("Creating appveyor")
    talk_to(HTTP.post, a, "/api/projects", Dict(
        "repositoryProvider" => "gitHub",
        "repositoryName" => user_repo(a) ) ) |> json_parse
end

function delete(a::AppVeyor)
    info("Deleting appveyor")
    talk_to(HTTP.delete, a, "/api/projects/$(a.username)/$(a.repo_code)")
end

function exists(a::AppVeyor)
    any(repos(a)) do repo
        repo["repositoryName"] == user_repo(a)
    end
end

function repo!(a::AppVeyor)
    a.repo_code = create(a)["slug"]
end
