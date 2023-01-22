# phonetic-names

**Phonetic Names** is a command line tool that adds Chinese phonetic names for your Contacts. This solves the issue that the contacts with Chinese names won't sort property under English system environment.

使用这个命令行工具来为你的中文联系人添加拼音姓名，以便在英文系统环境下，联系人 APP 可以正确排序中文联系人。

## Usage

```text
USAGE: phonetic-names [--dry] [--force] [--clean]

OPTIONS:
  -d, --dry               Dry run without modifying the contacts.
  -f, --force             Force update all phonetic names, even if the phonetic names already exist.
  -c, --clean             Clean all contact's phonetic names.
  -h, --help              Show help information.
```

If you do not specify any options, the tool will only add phonetic names for contacts that do not have phonetic names.

## Installation

Download the latest universal binary build from Github Release Page and copy the binary to one of your $PATH folders (`/usr/local/bin`).

**The project is written in Swift 5.7, Xcode 14.2, tested on macOS 13.1.** It should also work on macOS 10.11+ (The minimum OS version for [Contacts](https://developer.apple.com/documentation/contacts) API). The conversion from Chinese character to phonetic names is supported by `Founadtion`'s `.mandarinToLatin` transformation. If some of phonetic names are incorrect, you can clone this project and add your customized name maps.

## Predecessor

There're a few projects with the same functionality. I've tried them and found that they exist some permission issues for the latest OS or uses older APIs, so I decided to make a new one. You can also check them out if this tool is not working for you:

- [https://github.com/jjgod/apn](https://github.com/jjgod/apn)
- [https://github.com/lexrus/PhoneticContacts](https://github.com/lexrus/PhoneticContacts)