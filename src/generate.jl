export generate
"""
    generate(repo_name, create_appveyor = true)

Generate GitHub, Travis, and (optionally) AppVeyor remotes for a repository.
BE SURE TO ADD .jl AT THE END OF THE REPO_NAME FOR JULIA REPOSITORIES.
"""
function generate(repo_name; create_appveyor = true, github_time = 60, travis_time = 60)
    if !endswith(repo_name, ".jl")
        ArgumentError("repo_name $repo_name must end with .jl")
    end
    created_github = false
    created_appveyor = false
    github = GitHub(repo_name)
    travis = Travis(repo_name)
    appveyor = AppVeyor(repo_name)

    try
        if exists(github)
            error("github already exists")
        end
        create(github)
        created_github = true
        info("Waiting $github_time seconds for github creation")
        sleep(github_time)

        user!(travis)
        sync(travis)
        info("Waiting $travis_time seconds for travis syncing")
        sleep(travis_time)
        if !exists(travis)
            error("travis doesn't exist, likely due to incomplete syncing")
        end
        repo!(travis)
        create(travis)

        public_key, private_key = make_keys()
        key(github, ".documenter", public_key)
        key(travis, "DOCUMENTER_KEY", private_key)

        if create_appveyor
            if exists(appveyor)
                error("appveyor already exists")
            end
            repo!(appveyor)
            created_appveyor = true
        end
    catch x
        info("Ran into an error; cleaning up")
        if created_github
            delete(github)
        end
        if created_appveyor
            delete(appveyor)
        end
        rethrow(x)
    end
    github, travis, appveyor
end
