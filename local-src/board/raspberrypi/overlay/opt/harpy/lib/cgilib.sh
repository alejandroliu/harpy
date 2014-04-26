#!/bin/sh
lf="
"

add_http_header() {
  local k="$1"
  shift
  http_headers="$headers$k: $*\r\n"
}
add_html_head() {
  html_head="$html_head$*\r\n"
}
add_html_body() {
  html_body="$html_body$*\r\n"
}

add_html_pre() {
  local x=$(httpd -e "$*" | sed 's/&#10;/\n/g')
  html_body="$html_body<pre>\r\n$x\r\n</pre>\r\n"
}

response() {
  http_headers=""
  html_head=""
  html_body=""
  local content_type="text/html"
  local title=""
  local refresh=""

  while [ $# -gt 0 ] ; do
    case "$1" in
      --http=*)
	add_http_header ${1#--http=}
	;;
      --html=*)
	add_html_head "${1#--html=}"
	;;
      --body=*)
	add_html_body "${1#--body=}"
	;;
      --pre=*)
	add_html_pre "${1#--pre=}"
	;;
      --content-type=*)
	content_type="${1#--content-type=}"
	;;
      --no-content-type)
	content_type=""
	;;
      --title=*)
	title="${1#--title=}"
	;;
      --refresh=*)
	refresh="${1#--refresh=}"
	;;
      *)
	break
	;;
    esac
    shift
  done
  [ -n "$content_type" ] && add_http_header content-type $content_type
  if [ -n "$title"  ] ; then
    add_html_head "<title>$title</title>"
    html_body="<h1>$title</h1>\r\n$html_body"
  fi
  if [ -n "$refresh" ] ; then
    add_http_header Refresh "$refresh"
    add_html_head "<meta http-equiv=\"refresh\" content=\"$refresh\">"
  fi
  if [ -n "$http_headers" ] ; then
    echo -ne "$http_headers"
    echo -ne "\r\n"
  fi

  echo "<!DOCTYPE html>"
  echo "<html>"
  echo "<head>"
  echo -ne "$html_head"
  echo "</head>"
  echo "<body>"
  echo -ne "$html_body"
  echo "</body>"
  echo "</html>"
}
