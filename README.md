# DataAnalyzer

based on original work by [Jean-Pierre Ribreau (JPR)](https://kb.4d.com/assetid=77253)

## Modifications

* resolve data file alias or shortcut
* `4D.FileHandle` instead of `Open document`
* `CALL FORM` instead of `POST OUTSIDE CALL`
* `CALL WORKER` instead of `New process`
* run mulitple preëmptive processes in compiled mode
* export JSON
* export XLSX

<img src="https://github.com/user-attachments/assets/6b22c84e-9aa5-4bed-9552-ad47b84b625a" width=800 height=auto />

## TODO 

- [ ] support headless / tool4d
- [ ] support console output

## page 1

analysis starts as soon as data file is selected or dropped on the listbox

<img src="https://github.com/user-attachments/assets/f5fd0a5d-9b03-4005-b239-043f35c2993b" width=800 height=auto />

## page 2

basic stats about the data file

<img src="https://github.com/user-attachments/assets/624ed5ab-4b49-4000-9f27-8019f6ac2fc6" width=800 height=auto />
