module votp

import encoding.base32
import math

struct HOTP {
	secret []u8
	digits int
}

pub fn (h HOTP) generate_hotp(counter i64) string {
	msg := u64_to_bytes(counter);
	key := base32.decode(h.secret) or {
		return ""
	}

	hash := get_hash(msg, key);
	offset := hash[(hash.len) - 1] & 0xF;
	bincode :=
		(u32(hash[offset + 0]) & 0x7F) << 24 |
		(u32(hash[offset + 1]) & 0xFF) << 16 |
		(u32(hash[offset + 2]) & 0xFF) <<  8 |
		(u32(hash[offset + 3]) & 0xFF) <<  0 ;
	
	code := (bincode % math.powi(10, h.digits)).str();
	return '0'.repeat(h.digits - code.len) + code
}

pub fn new_hotp(secret []u8, digits int) HOTP {
	return HOTP{
		secret: secret,
		digits: digits,
	}
}

pub fn (h HOTP) verify(input string, counter i64) bool {
	token := new_hotp(h.secret, h.digits);
	code := token.generate_hotp(counter);
	return code == input
}

