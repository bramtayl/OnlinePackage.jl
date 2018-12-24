var documenterSearchIndex = {"docs": [

{
    "location": "#",
    "page": "OnlinePackage",
    "title": "OnlinePackage",
    "category": "page",
    "text": ""
},

{
    "location": "#OnlinePackage.USER_FILE",
    "page": "OnlinePackage",
    "title": "OnlinePackage.USER_FILE",
    "category": "constant",
    "text": "Where OnlinePackage will look for your user information\n\n\n\n\n\n"
},

{
    "location": "#OnlinePackage.delete-Tuple{OnlinePackage.User,Any}",
    "page": "OnlinePackage",
    "title": "OnlinePackage.delete",
    "category": "method",
    "text": "delete(u::User, repo_name)\n\ndelete a repository.\n\n\n\n\n\n"
},

{
    "location": "#OnlinePackage.put_online-Tuple{OnlinePackage.User,Any}",
    "page": "OnlinePackage",
    "title": "OnlinePackage.put_online",
    "category": "method",
    "text": "put_online(u::User, repo_name)\n\nput a repository online: create a github and travis repository (if they don\'t already exist) and connect them with a key.\n\njulia> using OnlinePackage\n\njulia> u = user(joinpath(dirname(pwd()), \"sample.toml\"));\n\njulia> put_online(u, \"Test.jl\")\n\njulia> delete(u, \"Test.jl\")\n\n\n\n\n\n"
},

{
    "location": "#OnlinePackage.user",
    "page": "OnlinePackage",
    "title": "OnlinePackage.user",
    "category": "function",
    "text": "user(user_file = USER_FILE)\n\ncreate a user profile from a file. by default, looks in USER_FILE\n\nthe file must contain a username, github_token, travis_token, and ssh_keygen_file. see the sample.toml file for an example.\n\nuse your github username.\n\nget a github_token here. make sure to check the \"public_repo\" scope.\n\nget your travis_token here.\n\nif ssh-keygen is in your path, just set ssh_keygen_file to \"ssh-keygen\". if not, it often comes prepacked with git; check PATH_TO_GIT/usr/bin/ssh-keygen\".\n\n\n\n\n\n"
},

{
    "location": "#OnlinePackage-1",
    "page": "OnlinePackage",
    "title": "OnlinePackage",
    "category": "section",
    "text": "Modules = [OnlinePackage]"
},

]}
