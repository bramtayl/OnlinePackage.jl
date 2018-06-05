repo_name = "Test34.jl"

username = settings("username")
github_token = settings("github_token")
appveyor_token = settings("appveyor_token")
ssh_keygen_file = settings("ssh_keygen_file")
set_up(username, github_token, appveyor_token, ssh_keygen_file = ssh_keygen_file)

github, travis, appveyor = generate(repo_name)
delete(github)
delete(appveyor)
