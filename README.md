# rrxx-packer
Collections of tools and scripts to easily pack and repack RRXX game and DLC files

# Usage
Drag and drop your .pac, .tex, .bpe, or .pach file onto unpack.bat to recursively unpack the entire archive.

Drag and drop a file or directory previously unpacked with above method onto repack.bat to recursively repack it to original state.

Note: naming of the files is important for the repack process so do not arbitrarily rename anything. Making other changes to unpacked files should be fine.

Known issues: repacking can sometimes fail in the final stage (e.g. ai.pac), simply drag it onto repack.bat one more time and it will complete
