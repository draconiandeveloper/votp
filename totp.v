module votp

import encoding.base32
import math
import time

struct TOTP {
	secret []u8
	digits int
	expiry int
}

pub fn (t TOTP) generate_totp() string {
	slice := u64((time.now().unix() - 10800) / t.expiry);
	message := u64_to_bytes(slice);
	key := base32.decode(t.secret) or {
		return ""
	}

	hash := get_hash(message, key);
	offset := hash[(hash.len) - 1] & 0xF;
	bincode :=
		(u32(hash[offset + 0]) & 0x7F) << 24 |
		(u32(hash[offset + 1]) & 0xFF) << 16 |
		(u32(hash[offset + 2]) & 0xFF) <<  8 |
		(u32(hash[offset + 3]) & 0xFF) <<  0 ;
	
	code := (bincode % math.powi(10, t.digits)).str();
	return '0'.repeat(t.digits - code.len) + code
}

pub fn new_totp(secret []u8, digits int, expiry int) TOTP {
	return TOTP{
		secret: secret,
		digits: digits,
		expiry: expiry,
	}
}

pub fn (t TOTP) verify(input string) bool {
	token := new_totp(t.secret, t.digits, t.expiry);
	code := token.generate_totp();

	padded := '0'.repeat(t.digits - code.len) + code;
	return padded == input
}

