pb ![calver](https://img.shields.io/badge/calver-2022.11.03-22bfda.svg?style=flat-square) [![Build Status](https://drone.tildegit.org/api/badges/tomasino/pb/status.svg)](https://drone.tildegit.org/tomasino/pb) ![license](https://img.shields.io/badge/license-GPL3-blue.svg?style=flat-square)
------

**pb** is a helper utility for using 0x0 pastebin services

pb  provides  an  easy-to-use  interface  for  uploading images or piping output to a 0x0
pastebin service. While it comes pre-configured with a  specific  pastebin,  the  service
endpoint can be overridden.

## Usage Examples

Upload 'scores.txt' to the pastebin

```bash
pb scores.txt
```

Upload piped output to the pastebin

```bash
echo 'Secret info' | pb
```

Upload a list of javascript files to the pastebin individually

```bash
find . -type f -name '*.js' -print | pb -f
```

Upload a file to a different pastebin endpoint

```bash
pb -s http://0x0.st scores.txt
```

Re-upload an image from the web

```bash
curl -s https://tildegit.org/_/static/img/gitea-lg.png | pb -e "png"
```

### Options

```bash
-h | --help)                    Show this help
-v | --version)                 Show current version number
-f | --file)                    Explicitly interpret stdin as filename
-c | --color)                   Pretty color output
-s | --server server_address)   Use alternative pastebin server address
-e | --extension bin_extension) Specify file extension used in the upload
```

### Install

On GNU systems:

```sh
sudo make install
```

On BSD systems:

The man-path `/usr/local/share/man` is not indexed by default on openbsd. Using the `/usr` prefix works around this issue.

```sh
doas make PREFIX=/usr install
```

### Uninstall

```sh
sudo make uninstall
```

On BSD systems:

```sh
doas make PREFIX=/usr uninstall
```

## Contributing

Pull requests are welcome. For major changes, please open an issue first to
discuss what you would like to change.

## License
[GPL3](LICENSE)
