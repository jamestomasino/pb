pb ![calver](https://img.shields.io/badge/calver-2018.08.14-22bfda.svg?style=flat-square) ![status](https://img.shields.io/badge/status-working-green.svg?style=flat-square) ![license](https://img.shields.io/badge/license-GPL3-blue.svg?style=flat-square)
------

**pb** is a helper utility for using 0x0 pastebin services

pb  provides  an  easy-to-use  interface  for  uploading images or piping output to a 0x0
pastebin service. While it comes pre-configured with a  specific  pastebin,  the  service
endpoint can be overridden.

## Usage

```bash
pb scores.txt
       Upload 'scores.txt' to the pastebin

echo 'Secret info' | pb
       Upload piped output to the pastebin

find . -type f -name '*.js' -print | pb -f
       Upload a list of files to the pastebin individually pb -s http://0x0.st scores.txt
       Upload a file to a different pastebin endpoint
```

### Options

```bash
  -h                        Show help
  -v                        Show current version number
  -f                        Explicitly interpret stdin as filename
  -s server_address         Use alternative pastebin server address
```

### Install

`sudo make install`

_Note: On systems without admin access the binary can be run directly from the
git repo, but will lack `man` support and command completion._

### Uninstall

`sudo make uninstall`

## Contributing

Pull requests are welcome. For major changes, please open an issue first to
discuss what you would like to change.

## License
[GPL3](LICENSE)
