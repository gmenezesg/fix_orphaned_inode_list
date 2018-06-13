# fix_orphaned_inode_list
When using pishrink, I've encountered the error "Inodes that were part of a corrupted orphan linked list found". 
This script attempts to fix orphaned inode list on img files.

In my case, I've generated a .img file using Win32DiskImager. When I ran pishrink on this generated .img file, the error showed up.

This script is made available "as is". I cannot be held responsible for further issues that may come up by executing this script.

Execute at your own risk!

Usage:

wget https://raw.githubusercontent.com/gmenezesg/fix_orphaned_inode_list/master/fix_orphaned_inode_list.sh

sudo chmod +x fix_orphaned_inode_list.sh

sudo ./fix_orphaned_inode_list.sh [imagefile.img]
