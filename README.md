# DevitoCli
CLI app for [Devito Link Shortener](https://github.com/supersimple/devito)

## Functions
`devito config`
shows the existing config settings.

`devito config --authtoken <AUTHTOKEN> --apiurl <APIURL>`
AUTHTOKEN will need to match the AUTHTOKEN env var in the Devito app.
APIURL is the URL used for the shortener, for example: "https://sprsm.pl"

`devito <URL>`
Generates a short code for the given URL.

`devito <URL> <SHORTCODE>`
Stores the url and shortcode given. If the shortcode is not unique, returns an error.

`devito info`
Prints a list of all links

`devito info <SHORTCODE>`
Prints info about a link

## Installation
Copy the `/devito` file into a location in your executable path.
For example `cp ./devito /usr/bin/devito`

You can also run the script from this directory using `./devito`

