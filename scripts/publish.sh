#!/usr/bin/env bash
# shellcheck disable=2154

# Initialize default values
argc_email="$LMNO_LOL_API_EMAIL"
argc_password="$LMNO_LOL_API_KEY"
argc_blog="crisidev"
argc_url="https://lmno.lol"
argc_cookie_file="$(pwd)/lmno.lol.$argc_blog.cookie"
argc_blog_file="$(pwd)/blog.md"

# generate blog update JSON payload
blog_data() {
    cat <<EOF
{
    "kind":"update",
    "payload":{
        "blog_name":"crisidev",
        "blog_source":$(jq -R -s '.' <"$argc_blog_file")
    }
}
EOF
}

# build blog from articles
build_blog() {
    directories=$(/bin/ls -d posts/* | sort -r)
    for directory in $directories; do
        if [ -d "$directory" ]; then
            echo "adding directory $directory to blog file"
            cat "$directory"/*.md >>"$argc_blog_file"
        fi
    done
    echo "adding header and description to blog file"
    cat posts/header.md >>"$argc_blog_file"
    echo "blog file of written to $argc_blog_file"
}

# login and get the cookie
login() {
    echo "logging into blog $argc_url/$argc_blog and store cookies into $argc_cookie_file"
    curl -s -b "$argc_cookie_file" -c "$argc_cookie_file" \
        -H "Content-Type: application/x-www-form-urlencoded" \
        -w '%{method} %{http_code} %{url_effective}  time: %{time_total}s, down: %{size_download}b, up: %{size_upload}b\n' \
        -d "email=$argc_email&password=$argc_password" \
        "$argc_url/signin?goto=/$argc_blog"
    if [ $? -eq 0 ]; then
        echo "Cookie successfully stored to file $argc_cookie_file"
    else
        echo "Error storing cookie to file $argc_cookie_file"
        exit 1
    fi
}

# upload new blog version
update_blog() {
    echo "uploading local blog file $argc_blog_file to $argc_url/$argc_blog"
    curl -s -b "$argc_cookie_file" -c "$argc_cookie_file" \
        -H 'Content-Type: application/json' \
        -w '\n%{method} %{http_code} %{url_effective}  time: %{time_total}s, down: %{size_download}b, up: %{size_upload}b\n' \
        --data-raw "$(blog_data)" "$argc_url/api"
    if [ $? -eq 0 ]; then
        echo "blog $argc_url/$argc_blog updates successfully"
    else
        echo "error updating blog $argc_url/$argc_blog"
    fi
}

# trap EXIT and remove the cookie file
cleanup() {
    trap 'rm -rf $argc_cookie_file' EXIT
    rm -rf "$argc_cookie_file" "$argc_blog_file"
}

echo "publishing blog $argc_url/$argc_blog for user $argc_email using local file $argc_blog_file"
cleanup
build_blog
login
update_blog
exit 0
