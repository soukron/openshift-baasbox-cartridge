#!/bin/bash

# login data
_server_url=http://$OPENSHIFT_DIY_IP:$OPENSHIFT_DIY_PORT
_user=admin
_password1=admin
_appcode=1234567890

# new password for admin
_password2=VerySecurePassw0rd

# colections
_collections=(
        genres
	movies
)

# users (user,password)
_users=(
	"api,apipassword"
)

# genres documents (name)
_genres=(
       Action
       Adventure
       Comedy
       Crime
       Horror
       SciFi
)

# movies documents (name, genre)
_movies=(
       "The GoodFather,Crime"
       "The Darknight,Action"
       "The Matrix,SciFi"
)

#
# function to access API
#
function cURL() {
        echo ${_method} ${_url} >> curl.log
        [ -f data.json ] && cat data.json >> curl.log

        if [ -z ${_auth_header} ]; then
                curl -H 'Accept: application/json'              \
                        -H 'Content-Type: application/json'     \
                        --data-binary @data.json -X ${_method}  \
                        -sS -k                                  \
                        ${_server_url}/${_url} 2> /dev/null |
                tee -a curl.log
        else
                curl -H 'Accept: application/json'              \
                        -H 'Content-Type: application/json'     \
                        -H "X-BB-SESSION: ${_auth_header}"      \
			-H "X-BAASBOX-APPCODE: ${_appcode}"	\
                        --data-binary @data.json -X ${_method}  \
                        -sS -k                                  \
                        ${_server_url}/${_url} 2> /dev/null |
                tee -a curl.log
        fi
        echo
}

#
# download jq parser
#
[ ! -f jq ] && wget https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 -O jq
chmod +x jq

#
# get authentication token
#
_url=login
_method=POST
cat > data.json <<EOF
{
	"username": "${_user}",
	"password": "${_password1}",
	"appcode": "${_appcode}"
}
EOF
_auth_header=`cURL | ./jq '.data ."X-BB-SESSION"' | tr -d \"`


#
# create collections
#
_method=POST
for _collection in "${_collections[@]}"; do
	_url=admin/collection/${_collection}
	cURL
done


#
# create genres documents 
#
for _genre in "${_genres[@]}"; do
	_url=document/genres
	_method=POST

	cat > data.json <<EOF
{
	"name": "${_genre}"
}
EOF
	_genre_id=`cURL | ./jq ".data .id" | tr -d '\"'`

	# allow registered users read this new document
	_url="document/genres/${_genre_id}/read/role/registered"
	_method=PUT
	cURL
done


#
# create movies documents
#
for _movie in "${_movies[@]}"; do
	_movie_name=`echo ${_movie} | cut -d, -f 1`
	_genre_name=`echo ${_movie} | cut -d, -f 2`

	# get genre id
	_url="document/genres?where=name='"${_genre_name}"'&fields=id" 
        _method=GET
        _genre_id=`cURL | ./jq ".data[0] .id" | tr -d '\"'`

	# create movie document
	cat > data.json <<EOF
{
	"name": "${_movie_name}",
        "genre_id": "${_genre_id}"
}
EOF
	_url=document/movies
	_method=POST
	_movie_id=`cURL | ./jq '.data .id' | tr -d '\"'`

	# create link between movie and genre
	_url=link/${_movie_id}/belongs_to_genre/${_genre_id}
	_method=POST
	cURL

	# allow registered users read this new document
	_url="document/movies/${_movie_id}/read/role/registered"
	_method=PUT
	cURL
done


#
# upload and activate plugins
#
_url=admin/plugin
_method=POST
for _plugin in `ls -1 plugins/`; do
	cat > data.json <<EOF
{
	"lang": "Javascript",
	"name": "${_plugin}",
	"encoded": "BASE64",
	"active": true,
	"code": "`base64 -w0 plugins/${_plugin}`"
}
EOF
	cURL
done


#
# create users
#
_url=user
_method=POST
for _user in "${_users[@]}"; do
	_user_name=`echo ${_user} | cut -d, -f 1`
	_user_password=`echo ${_user} | cut -d, -f 2`
	cat > data.json <<EOF
{
	"username": "${_user_name}",
	"password": "${_user_password}"
}
EOF
	cURL
done


#
# change admin's password
#
_url=me/password
_method=PUT
cat > data.json <<EOF
{
	"old": "${_password1}",
	"new": "${_password2}"
}
EOF
cURL

