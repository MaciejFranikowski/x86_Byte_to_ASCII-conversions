# x86_Byte_to_ASCII-conversions
Byte to ASCII conversion, fairly complicated conversion creating 3 byte ASCII data from one byte.
For each read byte outputs 3 bytes to STD_OUT: 2x HEX number ASCII codes + 1 ASCII code of SPACE.
The two output ascii bytes, have the same representation in binary, as the input byte's ASCII code split in two.

EXAMPLE:
If the read byte is the ascii code of '0', it'd contatin bits '00110000'. It's ascii code is: 30.
Output would be: '00110011', '00100000' ('3' '0') and the ascii space code.
