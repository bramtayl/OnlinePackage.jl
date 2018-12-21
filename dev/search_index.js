var documenterSearchIndex = {"docs": [

{
    "location": "#",
    "page": "OnlinePackage",
    "title": "OnlinePackage",
    "category": "page",
    "text": ""
},

{
    "location": "#OnlinePackage.copy_package-Tuple{Any,Any}",
    "page": "OnlinePackage",
    "title": "OnlinePackage.copy_package",
    "category": "method",
    "text": "copy_package(model, package)\n\ncreate a new package based off of model. model must be in the working directory.\n\n\n\n\n\n"
},

{
    "location": "#OnlinePackage.put_online-Tuple{Any}",
    "page": "OnlinePackage",
    "title": "OnlinePackage.put_online",
    "category": "method",
    "text": "put_online(repo_name)\n\nput a repository online: create a github and travis repository (if they don\'t already exist) and connect them with a key.\n\n\n\n\n\n"
},

{
    "location": "#OnlinePackage.set_up-Tuple{Any,Any,Any}",
    "page": "OnlinePackage",
    "title": "OnlinePackage.set_up",
    "category": "method",
    "text": "set_up(username, github_token, travis_token, ssh_keygen_file = \"ssh-keygen\")\n\nset up OnlinePackage.\n\nget a github_token here. make sure to check the \"public_repo\" scope.\n\nget your travis_token here.\n\nthe default ssh_keygen_file assumes ssh-keygen is in your path. if not, it often comes prepacked with git; check PATH_TO_GIT/usr/bin/ssh-keygen\".\n\n\n\n\n\n"
},

{
    "location": "#OnlinePackage-1",
    "page": "OnlinePackage",
    "title": "OnlinePackage",
    "category": "section",
    "text": "Modules = [OnlinePackage]"
},

]}
