var documenterSearchIndex = {"docs":
[{"location":"#OnlinePackage-1","page":"OnlinePackage","title":"OnlinePackage","text":"","category":"section"},{"location":"#","page":"OnlinePackage","title":"OnlinePackage","text":"","category":"page"},{"location":"#","page":"OnlinePackage","title":"OnlinePackage","text":"Modules = [OnlinePackage]","category":"page"},{"location":"#OnlinePackage.USER_FILE","page":"OnlinePackage","title":"OnlinePackage.USER_FILE","text":"where OnlinePackage will look for your user information\n\n\n\n\n\n","category":"constant"},{"location":"#OnlinePackage.delete-Tuple{OnlinePackage.User,Any}","page":"OnlinePackage","title":"OnlinePackage.delete","text":"delete(user::User, repo_name)\n\ndelete a repository.\n\n\n\n\n\n","category":"method"},{"location":"#OnlinePackage.get_user","page":"OnlinePackage","title":"OnlinePackage.get_user","text":"get_user(user_file = USER_FILE)\n\ncreate a user profile from a file. by default, looks in USER_FILE\n\nthe file must contain a username, github_token, travis_token, and ssh_keygen_file. see the sample.toml file for an example.\n\nuse your github username.\n\nget a github_token here. make sure to check the public_repo scope, and optionally, the delete_repo scope.\n\nget your travis_token here.\n\nif ssh-keygen is in your path, just set ssh_keygen_file to \"ssh-keygen\". if not, it often comes prepacked with git; check PATH_TO_GIT/usr/bin/ssh-keygen\".\n\n\n\n\n\n","category":"function"},{"location":"#OnlinePackage.put_online-Tuple{OnlinePackage.User,Any}","page":"OnlinePackage","title":"OnlinePackage.put_online","text":"put_online(user::User, repo_name)\n\nput a repository online: create a github and travis repository (if they don'travis_remote already exist) and connect them with a key.\n\njulia> using OnlinePackage\n\njulia> user = get_user(joinpath(dirname(pwd()), \"sample.toml\"));\n\njulia> put_online(user, \"Test.jl\")\n\njulia> delete(user, \"Test.jl\")\n\n\n\n\n\n","category":"method"}]
}