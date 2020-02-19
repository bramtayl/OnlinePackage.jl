var documenterSearchIndex = {"docs":
[{"location":"#OnlinePackage-1","page":"OnlinePackage","title":"OnlinePackage","text":"","category":"section"},{"location":"#","page":"OnlinePackage","title":"OnlinePackage","text":"Modules = [OnlinePackage]","category":"page"},{"location":"#","page":"OnlinePackage","title":"OnlinePackage","text":"Modules = [OnlinePackage]","category":"page"},{"location":"#OnlinePackage.USER_FILE","page":"OnlinePackage","title":"OnlinePackage.USER_FILE","text":"where OnlinePackage will look for your user information\n\n\n\n\n\n","category":"constant"},{"location":"#OnlinePackage.delete-Tuple{OnlinePackage.User,Any}","page":"OnlinePackage","title":"OnlinePackage.delete","text":"delete(user::User, repo_name)\n\nDelete a repository.\n\n\n\n\n\n","category":"method"},{"location":"#OnlinePackage.get_user","page":"OnlinePackage","title":"OnlinePackage.get_user","text":"get_user(user_file = USER_FILE)\n\nCreate a user profile from a TOML file. By default, looks in USER_FILE\n\nThe file must contain a username, github_token, and ssh_keygen_file. See the sample.toml file in this repository for an example.\n\nUse your github username.\n\nGet a github_token here. Make sure to check the public_repo scope, and optionally, the delete_repo scope.\n\nIf ssh-keygen is in your path, just set ssh_keygen_file to \"ssh-keygen\". If not, it often comes prepacked with git; check PATH_TO_GIT/usr/bin/ssh-keygen\".\n\n\n\n\n\n","category":"function"},{"location":"#OnlinePackage.put_online-Tuple{OnlinePackage.User,Any}","page":"OnlinePackage","title":"OnlinePackage.put_online","text":"put_online(user::User, repo_name)\n\nPut a repository online: put it on github, and create an SSH key to allow github actions to push to github. If the repository already exists, it will create a new set of keys.\n\njulia> using OnlinePackage\n\njulia> user = get_user(OnlinePackage.SAMPLE_FILE);\n\njulia> put_online(user, \"Test.jl\")\n\njulia> put_online(user, \"Test.jl\")\n\njulia> delete(user, \"Test.jl\")\n\n\n\n\n\n","category":"method"}]
}
