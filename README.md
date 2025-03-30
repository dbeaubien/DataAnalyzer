![version](https://img.shields.io/badge/version-20%2B-E23089)
![platform](https://img.shields.io/static/v1?label=platform&message=mac-intel%20|%20mac-arm%20|%20win-64&color=blue)
[![license](https://img.shields.io/github/license/miyako/DataAnalyzer)](LICENSE)
![downloads](https://img.shields.io/github/downloads/miyako/DataAnalyzer/total)

# DataAnalyzer

based on original work by [Jean-Pierre Ribreau (JPR)](https://kb.4d.com/assetid=77253)

## dependencies.json

 ```json
{
	"dependencies": {
		"DataAnalyzer": {
			"github": "miyako/DataAnalyzer",
			"version": "latest"
		}
	}
}
```

## Modifications

* resolve data file alias or shortcut
* `4D.FileHandle` instead of `Open document`
* `CALL FORM` instead of `POST OUTSIDE CALL`
* `CALL WORKER` instead of `New process`
* use preëmptive process in compiled mode
* export JSON
* export XLSX

## TODO 

- [ ] support headless / tool4d
- [ ] support console output

## page 1

analysis starts as soon as data file is selected or dropped on the listbox

<img src="https://github.com/user-attachments/assets/f5fd0a5d-9b03-4005-b239-043f35c2993b" width=800 height=auto />

## page 2

basic stats about the data file

<img src="https://github.com/user-attachments/assets/624ed5ab-4b49-4000-9f27-8019f6ac2fc6" width=800 height=auto />
