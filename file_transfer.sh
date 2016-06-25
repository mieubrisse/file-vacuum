#!/usr/bin/expect -f
# Sucks files from the remote, source directory to the local, target directory
#   argv[0]     source directory to pull files from
#   argv[1]     destination directory to put files into
#   argv[2]     username@host combo
#   argv[3]     either 'put' or 'get' if user wants to push or pull files to/from remote respectively

# Changeable options
if {[llength $argv] != 4} {
    send_user "Usage: file_transfer \[source dir\] \[dest dir\] \[username@host\] \[put|get\]"
    exit
}
set src_dir  [lindex $argv 0]
set target_dir   [lindex $argv 1]
set username_host   [lindex $argv 2]
set put_get     [lindex $argv 3]

spawn   sftp $username_host
set timeout -1
# Prompt for password if needed; otherwise, notify of connect
expect {
    "*assword*" {
        interact { 
            -nobuffer -re "(.*)\r" return
            timeout 20 {
                send_user "Too long to type password; logging out"
                exit
            }
        }
        exp_continue
    }
    "*onnected*" {}
    default exit
}
set timeout 2
expect  "sftp>" 
# Sequence for uploading files to reote server
if {$put_get == "put"} {
    send    "lcd $src_dir\r"
    expect {
        "sftp>" {}
        default exit
    }
    send    "cd $target_dir\r"
    expect {
        "sftp>" {}
        default exit
    }
    set timeout -1
    send    "put *\r"
# Sequence for pulling files from remote server
} else {
    send    "cd $src_dir\r"
    expect {
        "sftp>" {}
        default exit
    }
    send    "lcd $target_dir\r"
    expect {
        "sftp>" {}
        default exit
    }
    set timeout -1
    send    "get *\r"
}
expect {
    "sftp>" {}
    default exit
}
send    "exit"
exit
