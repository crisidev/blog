#!/usr/bin/env bash
# shellcheck disable=2154

# Initialize default values
argc_email="bigo@crisidev.org"
argc_blog="crisidev"
argc_url="https://lmno.lol"
argc_cookie_file="$(pwd)/lmno.lol.$argc_blog.cookie"
argc_blog_file="$(pwd)/blog.md"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
    -e | --email)
        argc_email="$2"
        shift 2
        ;;
    -b | --blog)
        argc_blog="$2"
        shift 2
        ;;
    -u | --url)
        argc_url="$2"
        shift 2
        ;;
    -c | --cookie-file)
        argc_cookie_file="$2"
        shift 2
        ;;
    -f | --blog-file)
        argc_blog_file="$2"
        shift 2
        ;;
    -h | --help)
        echo "USAGE: $0 [OPTIONS]"
        echo
        echo "OPTIONS:"
        echo "  -e, --email <EMAIL>              [default: $argc_email]"
        echo "  -b, --blog <BLOG>                [default: $argc_blog]"
        echo "  -u, --url <URL>                  [default: $argc_url]"
        echo "  -c, --cookie-file <COOKIE-FILE>  [default: $argc_cookie_file]"
        echo "  -f, --blog-file <BLOG-FILE>      [default: $argc_blog_file]"
        echo "  -h, --help"
        exit 0
        ;;
    *)
        echo "Error: Unknown option '$1'"
        exit 1
        ;;
    esac
done

# generate blog update JSON payload
generate_post_data() {
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

echo "Updating blog $argc_url/$argc_blog for user $argc_email using local file $argc_blog_file"

# trap EXIT and remove the cookie file
rm -rf "$argc_cookie_file"
trap 'rm -rf $argc_cookie_file' EXIT

# login and get the cookie
echo "Logging into blog $argc_url/$argc_blog and store cookies into $argc_cookie_file"
curl -s -b "$argc_cookie_file" -c "$argc_cookie_file" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -w '%{method} %{http_code} %{url_effective}  time: %{time_total}s, down: %{size_download}b, up: %{size_upload}b\n' \
    -d "email=$argc_email&password=$LMNO_LOL_API_KEY" \
    "$argc_url/signin?goto=/$argc_blog"
if [ $? -eq 0 ]; then
    echo "Cookie successfully stored to file $argc_cookie_file"
else
    echo "Error storing cookie to file $argc_cookie_file"
    exit 1
fi

# upload new blog version
echo "Uploading local blog file $argc_blog_file to $argc_url/$argc_blog"
curl -s -b "$argc_cookie_file" -c "$argc_cookie_file" \
    -H 'Content-Type: application/json' \
    -w '\n%{method} %{http_code} %{url_effective}  time: %{time_total}s, down: %{size_download}b, up: %{size_upload}b\n' \
    --data-raw "$(generate_post_data)" "$argc_url/api"
if [ $? -eq 0 ]; then
    echo "Blog $argc_url/$argc_blog updates successfully"
else
    echo "Error updating blog $argc_url/$argc_blog"
fi

exit 0
