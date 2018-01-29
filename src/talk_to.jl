json_string(d::Dict) =
    if d == Dict()
        ""
    else
        d |> JSON.json |> string
    end

json_parse(r::HTTP.Response) = r |> HTTP.body |> String |> JSON.parse

function http_error(response)
    status_number = response |> HTTP.status
    status_text = response |> HTTP.statustext
    result_string = response |> HTTP.body |> String
    error("$status_number $status_text: $result_string")
end

function talk_to(f, remote, url, body = Dict())
    response = f(
        string(base_url(remote), url),
        headers = headers(remote),
        body = json_string(body)
    )
    status_number = response |> HTTP.status
    if status_number >= 300
        http_error(response)
    end
    response
end

user_repo(r::Remote) = "$(r.username)/$(r.repo_name)"
